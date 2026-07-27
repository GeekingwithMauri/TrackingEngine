import Firebase
import FirebaseRemoteConfig
import TrackingEngineCore

extension RemoteConfigFacade {
    /// Wires Remote Config and starts a fetch. Call alongside
    /// `TrackingEngineFacade.setup()`; order between the two doesn't matter,
    /// both configure the Firebase app if nobody has yet.
    ///
    /// - Parameters:
    ///   - defaults: every flag key mapped to its baked-in value. Seeding these
    ///     is what makes an un-fetched read return the app's own default rather
    ///     than Remote Config's blanket `false`.
    ///   - minimumFetchInterval: Firebase's own default is 12 hours, which is
    ///     right for release and useless while developing — a console toggle
    ///     appears to do nothing for half a day. Pass `0` from DEBUG builds.
    ///     It lives here as an argument rather than a `#if DEBUG` because
    ///     `DEBUG` is reliably defined in the app target and merely usually
    ///     defined in a package target, and the failure is silent either way.
    public static func setup(
        defaults: [String: Bool],
        minimumFetchInterval: TimeInterval = 43_200
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
