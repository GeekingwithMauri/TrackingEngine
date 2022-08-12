@testable import TrackingEngine

final class TrackingLoggableSpy: TrackingLoggable {
    var invokedTrack = false
    var invokedTrackCount = 0
    var invokedTrackParameters: (eventName: String, parameters: [String: Any]?)?
    var invokedTrackParametersList = [(eventName: String, parameters: [String: Any]?)]()

    func track(eventName: String, parameters: [String: Any]?) {
        invokedTrack = true
        invokedTrackCount += 1
        invokedTrackParameters = (eventName, parameters)
        invokedTrackParametersList.append((eventName, parameters))
    }
}
