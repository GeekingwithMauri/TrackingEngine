/// Firebase-free entry point for feature flags, mirroring `TrackingEngineFacade`.
///
/// `provider` stays `nil` until `setup(defaults:)` (in the `TrackingEngine`
/// product) assigns one, and every read falls back to the caller's default
/// meanwhile. That is what lets a test host link only `TrackingEngineCore`,
/// never call `setup`, and still resolve every flag — with Firebase absent from
/// the process, exactly as `logger == nil` does for analytics.
public struct RemoteConfigFacade {
    public static var provider: FlagResolving?

    public static func configure(with provider: FlagResolving) {
        Self.provider = provider
    }

    /// - Returns: the remote value, or `defaultValue` when no provider is wired
    ///   or the provider has nothing for this key.
    public static func isEnabled(
        _ key: String,
        default defaultValue: Bool
    ) -> Bool {
        provider?.isEnabled(
            key,
            default: defaultValue
        ) ?? defaultValue
    }
}
