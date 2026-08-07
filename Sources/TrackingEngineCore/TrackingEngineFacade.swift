public struct TrackingEngineFacade {
    public static var logger: TrackingLoggable?

    public static func configure(with logger: TrackingLoggable) {
        Self.logger = logger
    }

    public static func log(
        eventName: String,
        parameters: [String: Any]?
    ) {
        logger?.track(
            eventName: eventName,
            parameters: parameters
        )
        print("event: \(eventName) - parameters: \(parameters ?? [:])")
    }

    public static func log(
        errorName: String,
        parameters: [String: Any]
    ) {
        logger?.log(
            errorName: errorName,
            parameters: parameters
        )
        print("event: \(errorName) - parameters: \(parameters)")
    }

    /// Passthrough to the logger's crash-report metadata. A no-op while
    /// `logger` is `nil`, exactly like `log`.
    public static func setCustomValue(
        _ value: String,
        forKey key: String
    ) {
        logger?.setCustomValue(
            value,
            forKey: key
        )
    }
}
