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
}
