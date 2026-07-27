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
}
