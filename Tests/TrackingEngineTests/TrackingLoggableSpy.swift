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

    var invokedLog = false
    var invokedLogCount = 0
    var invokedLogParameters: (errorName: String, parameters: [String: Any])?
    var invokedLogParametersList = [(errorName: String, parameters: [String: Any])]()

    func log(errorName: String, parameters: [String: Any]) {
        invokedLog = true
        invokedLogCount += 1
        invokedLogParameters = (errorName, parameters)
        invokedLogParametersList.append((errorName, parameters))
    }
}
