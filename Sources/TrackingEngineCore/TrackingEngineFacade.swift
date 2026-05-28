public struct TrackingEngineFacade {
    public static var logger: TrackingLoggable?

    public static func configure(with logger: TrackingLoggable) {
        Self.logger = logger
    }

    public static func log(eventName: String, parameters: [String: Any]?) {
        logger?.track(eventName: eventName, parameters: parameters)
        print("event: \(eventName) - parameters: \(parameters ?? [:])")
    }

    public static func log(errorName: String, parameters: [String: Any]) {
        logger?.log(errorName: errorName, parameters: parameters)
        print("event: \(errorName) - parameters: \(parameters)")
    }
}
