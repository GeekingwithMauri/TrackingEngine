import Firebase

public struct TrackingEngineFacade {
    static var logger: TrackingLoggable?

    /// Initializes the tracking mechanism (should it be required). To be called before logging events
    public static func setup() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        Self.logger = TrackingLog()
    }

    /// Tracks user's events on the cloud provider. For the time being, that is **Firebase**
    /// - Parameters:
    ///   - eventName: event name to be tracked. I.e. _view_appeared_, _button_tapped_ and so forth
    ///   - parameters: The dictionary of event parameters. Passing `nil` indicates that the event has no parameters.
    public static func log(eventName: String, parameters: [String: Any]?) {
        Self.logger?.track(eventName: eventName, parameters: parameters)
        print("event: \(eventName) - parameters: \(parameters ?? [:])")
    }

    /// Tracks errors alongside its context on the cloud provider. For the time being, that is **Firebase**
    /// - Parameters:
    ///   - errorName: error name to be tracked.
    ///   - parameters: The dictionary of metadata context. 
    public static func log(errorName: String, parameters: [String: Any]) {
    }
}
