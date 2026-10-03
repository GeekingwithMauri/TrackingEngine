import Experiment
import TrackingEngineCore

/// Reads flags and experiment variants from Amplitude Experiment, through the
/// same `FlagResolving` seam `RemoteConfigResolver` serves from Firebase.
struct AmplitudeFlagResolver: FlagResolving {
    let client: ExperimentClient

    func isEnabled(
        _ key: String,
        default defaultValue: Bool
    ) -> Bool {
        switch resolution(key) {
        case .remote(let value):
            return value
        case .unavailable:
            return defaultValue
        }
    }

    /// Reading a variant is also an *exposure*: the SDK tracks one per flag and
    /// variant into Amplitude analytics, which is what experiment analysis counts.
    func resolution(_ key: String) -> RemoteFlagResolution {
        Self.resolution(of: client.variant(key))
    }

    /// Variant values that mean "not on for this install" even though the service
    /// answered. `off` is Amplitude's default variant; `control` is the default name
    /// of an experiment's baseline arm.
    static let offValues: Set<String> = ["off", "control"]

    /// Lifted out of the client so the mapping is testable; `variant()` on a real
    /// client needs a fetch.
    ///
    /// Three shapes come back from `variant(key)` with no fallback:
    ///
    /// - **Empty** (no key, value or metadata): nothing fetched yet, the fetch failed, or the
    ///   key does not exist in the deployment. Not an answer — the caller's default applies.
    /// - **Default** (`metadata.default == true`, key `off`, no value): the service evaluated
    ///   the flag and this install is *not* in it — inactive flag, or outside every segment.
    ///   The console's answer, so a kill switch flipped off reads `false`, never the
    ///   baked-in default.
    /// - **Assigned**: a variant with a value. `on`, `treatment` or anything else is `true`;
    ///   `offValues` are `false`.
    static func resolution(of variant: Variant) -> RemoteFlagResolution {
        let isDefault = (variant.metadata?["default"] as? Bool) == true || variant.key == "off"

        if isDefault {
            return .remote(false)
        }

        guard let value = variant.value else {
            return .unavailable
        }

        return .remote(!offValues.contains(value))
    }
}
