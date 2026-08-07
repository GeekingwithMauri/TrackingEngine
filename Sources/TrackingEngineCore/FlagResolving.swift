/// What the flag service actually had for a key — as opposed to what the caller
/// decided to do about it.
///
/// `isEnabled` cannot express this: it answers a `Bool`, so "the console says
/// off" and "there is nothing here" come back identical. That is fine for a
/// kill switch, where both mean *don't*, and wrong for an experiment, where one
/// means "assigned to control" and the other means "not assigned at all".
public enum RemoteFlagResolution: Equatable {
    /// A value that was fetched and activated from the remote service — the
    /// console's answer, or an experiment variant assigned to this install.
    case remote(Bool)

    /// The service has nothing for this key: no provider wired, no fetch
    /// landed, the fetch failed, the key does not exist — or **only the host's
    /// own seeded default is present**, which is the host's opinion echoed back
    /// to it rather than an answer.
    case unavailable
}

/// Reads a remotely-controlled boolean flag. The flag analogue of
/// `TrackingLoggable`: declared here, in the Firebase-free product, so a host
/// app's call sites depend on this and never on Remote Config.
public protocol FlagResolving {
    /// - Parameter defaultValue: what to answer when the key is unknown or no
    ///   fetch has landed yet. Resolvers must never invent a value.
    func isEnabled(
        _ key: String,
        default defaultValue: Bool
    ) -> Bool

    /// The same read, without collapsing "off" into "absent". Prefer
    /// `isEnabled` unless the *reason* for a `false` changes what the caller
    /// does — which is the case for experiment assignment, and almost nothing
    /// else.
    func resolution(_ key: String) -> RemoteFlagResolution
}

extension FlagResolving {
    /// Default for resolvers that cannot tell a real remote value from a
    /// fallback. `.unavailable` is the fail-safe answer: it sends the caller to
    /// its own default, which is exactly where it would have landed before this
    /// method existed.
    public func resolution(_ key: String) -> RemoteFlagResolution {
        .unavailable
    }
}
