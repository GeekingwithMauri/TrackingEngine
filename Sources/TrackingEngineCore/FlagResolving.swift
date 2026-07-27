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
}
