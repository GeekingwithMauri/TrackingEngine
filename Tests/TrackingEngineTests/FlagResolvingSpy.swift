import TrackingEngineCore

final class FlagResolvingSpy: FlagResolving {
    var stubbedValues = [String: Bool]()

    var invokedIsEnabled = false
    var invokedIsEnabledCount = 0
    var invokedIsEnabledParameters: (key: String, defaultValue: Bool)?

    func isEnabled(
        _ key: String,
        default defaultValue: Bool
    ) -> Bool {
        invokedIsEnabled = true
        invokedIsEnabledCount += 1
        invokedIsEnabledParameters = (key, defaultValue)

        return stubbedValues[key] ?? defaultValue
    }

    var stubbedResolutions = [String: RemoteFlagResolution]()

    var invokedResolution = false
    var invokedResolutionCount = 0
    var invokedResolutionKey: String?

    func resolution(_ key: String) -> RemoteFlagResolution {
        invokedResolution = true
        invokedResolutionCount += 1
        invokedResolutionKey = key

        return stubbedResolutions[key] ?? .unavailable
    }
}
