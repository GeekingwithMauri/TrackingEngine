import Firebase
import FirebaseRemoteConfig
import TrackingEngineCore

extension RemoteConfigFacade {
    /// Firebase's own minimum fetch interval, 12 hours. Public so a host passing
    /// a DEBUG override doesn't have to restate the release value alongside it.
    public static let defaultFetchInterval: TimeInterval = 12 * 60 * 60

    /// Wires Remote Config and starts a fetch. Call alongside
    /// `TrackingEngineFacade.setup()`; order between the two doesn't matter,
    /// both configure the Firebase app if nobody has yet.
    ///
    /// - Parameters:
    ///   - defaults: every flag key mapped to its baked-in value. Seeding these
    ///     is what makes an un-fetched read return the app's own default rather
    ///     than Remote Config's blanket `false`.
    ///   - traits: facts about *this install* that the remote service may branch
    ///     on — an opaque bag the host fills and the console matches against, so
    ///     targeting a flag at particular installs is a dashboard edit rather
    ///     than a release. Empty by default, which is exactly the behaviour
    ///     every existing caller already has.
    ///
    ///     **They are published before the fetch, and that is the whole reason
    ///     this is a parameter rather than a method to call afterwards.** The
    ///     service evaluates conditions against whatever traits it holds *at
    ///     fetch time*; setting them after `setup` returns would miss the first
    ///     fetch, and in release the next one is `defaultFetchInterval` away —
    ///     so a targeted install would sit on the untargeted value for twelve
    ///     hours. Passing them in makes the ordering unmissable.
    ///
    ///     Values are strings because that is what identity-shaped traits are.
    ///     **A trait the console must compare *numerically* — a bucket, a
    ///     score, a tier — is not served by this**: string comparison orders
    ///     lexicographically, so `"9" > "50"`. Adding a numeric overload is the
    ///     upgrade path, and it is additive whenever someone needs it.
    ///   - minimumFetchInterval: defaults to `defaultFetchInterval`, which is
    ///     right for release and useless while developing — a console toggle
    ///     appears to do nothing for half a day. Pass `0` from DEBUG builds.
    ///     It lives here as an argument rather than a `#if DEBUG` because
    ///     `DEBUG` is reliably defined in the app target and merely usually
    ///     defined in a package target, and the failure is silent either way.
    public static func setup(
        defaults: [String: Bool],
        traits: [String: String] = [:],
        minimumFetchInterval: TimeInterval = defaultFetchInterval
    ) {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = minimumFetchInterval
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(defaults.mapValues { NSNumber(value: $0) })

        // Assigned before the fetch, not in its completion: the resolver reads
        // whatever Remote Config currently holds, so it answers from `defaults`
        // now and from the console the moment activation lands. Waiting for the
        // callback would leave every flag unreadable during launch and write a
        // mutable static from a background queue for no gain.
        configure(with: RemoteConfigResolver(remoteConfig: remoteConfig))

        publish(
            traits: traits,
            setting: { traits in
                try await remoteConfig.setCustomSignals(traits.mapValues { .string($0) })
            },
            thenFetching: { fetchAndActivate(remoteConfig) }
        )
    }

    /// Publishes traits, **then** fetches — and fetches either way.
    ///
    /// Both effects arrive as closures for the same reason
    /// `RemoteConfigResolver.resolution(source:value:)` is a lifted static: the
    /// real ones configure a `FirebaseApp` and open a socket, so the ordering
    /// that is the entire point of this function cannot otherwise be observed.
    /// The SDK's own `CustomSignalValue` is no help either — its payload is a
    /// private enum with no `Equatable`, so a test can neither read a signal
    /// back nor compare two.
    ///
    /// - Parameters:
    ///   - traits: empty is not a degenerate case of publishing. It is every
    ///     caller that predates this parameter, and it reaches the fetch by
    ///     exactly the path it always did — synchronously, no `Task`, no
    ///     suspension inserted ahead of the flags.
    ///   - setSignals: publishing. A throw costs *targeting* only.
    ///   - fetch: the flag fetch, which must happen regardless. Letting a
    ///     rejected trait swallow it would cost every flag including the kill
    ///     switches — by far the larger failure.
    static func publish(
        traits: [String: String],
        setting setSignals: @escaping ([String: String]) async throws -> Void,
        thenFetching fetch: @escaping () -> Void
    ) {
        guard !traits.isEmpty else {
            fetch()

            return
        }

        Task {
            do {
                try await setSignals(traits)
            } catch {
                // The SDK rejects the whole batch on a key over 250 characters,
                // a string value over 500, or more than 100 signals — so this
                // is the branch a malformed trait actually takes, and it must
                // not be silent or the console shows a condition matching
                // nobody with nothing to explain why.
                TrackingEngineFacade.log(
                    errorName: "remoteConfigTraitsRejected",
                    parameters: ["description": error.localizedDescription]
                )
            }

            fetch()
        }
    }

    private static func fetchAndActivate(_ remoteConfig: RemoteConfig) {
        remoteConfig.fetchAndActivate { _, error in
            if let error {
                TrackingEngineFacade.log(
                    errorName: "remoteConfigFetchFailed",
                    parameters: ["description": error.localizedDescription]
                )
            }
        }
    }
}
