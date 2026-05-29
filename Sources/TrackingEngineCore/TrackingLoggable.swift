public protocol TrackingLoggable {
    func track(eventName: String, parameters: [String: Any]?)
    func log(errorName: String, parameters: [String: Any])
}
