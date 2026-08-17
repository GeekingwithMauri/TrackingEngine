import TrackingEngineCore

final class TrackingLoggableSpy: TrackingLoggable {
    var invokedTrack = false
    var invokedTrackCount = 0
    var invokedTrackParameters: (eventName: String, parameters: [String: Any]?)?
    var invokedTrackParametersList = [(eventName: String, parameters: [String: Any]?)]()

    func track(
        eventName: String,
        parameters: [String: Any]?
    ) {
        invokedTrack = true
        invokedTrackCount += 1
        invokedTrackParameters = (eventName, parameters)
        invokedTrackParametersList.append((eventName, parameters))
    }

    var invokedLog = false
    var invokedLogCount = 0
    var invokedLogParameters: (errorName: String, parameters: [String: Any])?
    var invokedLogParametersList = [(errorName: String, parameters: [String: Any])]()

    func log(
        errorName: String,
        parameters: [String: Any]
    ) {
        invokedLog = true
        invokedLogCount += 1
        invokedLogParameters = (errorName, parameters)
        invokedLogParametersList.append((errorName, parameters))
    }

    var invokedSetCustomValue = false
    var invokedSetCustomValueCount = 0
    var invokedSetCustomValueParameters: (value: String, key: String)?

    func setCustomValue(
        _ value: String,
        forKey key: String
    ) {
        invokedSetCustomValue = true
        invokedSetCustomValueCount += 1
        invokedSetCustomValueParameters = (value, key)
    }

    var invokedSetUserID = false
    var invokedSetUserIDCount = 0
    var invokedSetUserIDParameter: String??

    func setUserID(_ id: String?) {
        invokedSetUserID = true
        invokedSetUserIDCount += 1
        invokedSetUserIDParameter = id
    }
}

/// A conformer that implements **only** the two required members. Its existence is the
/// proof that every later addition to `TrackingLoggable` carries a working default: this
/// file stops compiling the moment one of them becomes a requirement, which is a louder
/// failure than a comment promising the same thing.
final class BareTrackingLoggable: TrackingLoggable {
    /// Flipped by either required member, so a default implementation that quietly routed
    /// itself into `track` or `log` would be caught rather than assumed absent.
    var recordedSomething = false

    func track(
        eventName: String,
        parameters: [String: Any]?
    ) {
        recordedSomething = true
    }

    func log(
        errorName: String,
        parameters: [String: Any]
    ) {
        recordedSomething = true
    }
}
