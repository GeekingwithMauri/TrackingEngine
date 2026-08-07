import FirebaseRemoteConfig
import TrackingEngineCore

struct RemoteConfigResolver: FlagResolving {
    let remoteConfig: RemoteConfig

    func isEnabled(
        _ key: String,
        default defaultValue: Bool
    ) -> Bool {
        let value = remoteConfig.configValue(forKey: key)

        // `.static` means Remote Config has never heard of this key — neither
        // fetched nor seeded. Its `boolValue` is `false` regardless, so reading
        // it here would silently override a caller asking for `default: true`.
        guard value.source != .static else {
            return defaultValue
        }

        return value.boolValue
    }

    func resolution(_ key: String) -> RemoteFlagResolution {
        let value = remoteConfig.configValue(forKey: key)

        return Self.resolution(
            source: value.source,
            value: value.boolValue
        )
    }

    /// The source check, lifted out of the `RemoteConfigValue` it came from so
    /// it can be tested — a `RemoteConfigValue` with a chosen source cannot be
    /// constructed by a caller.
    ///
    /// Only `.remote` is an answer:
    ///
    /// - `.static` — Remote Config has never heard of this key.
    /// - `.default` — the value the **host seeded** via `setup(defaults:)`.
    ///   This is the one that looks like an answer and is not: seeding is what
    ///   makes an un-fetched read return the host's own default, so reporting
    ///   it as `.remote` would turn "never fetched" into "fetched and off" for
    ///   every flag the host seeds, which is all of them.
    /// - `.remote` — fetched and activated. The only value the console owns.
    static func resolution(
        source: RemoteConfigSource,
        value: @autoclosure () -> Bool
    ) -> RemoteFlagResolution {
        guard source == .remote else {
            return .unavailable
        }

        return .remote(value())
    }
}
