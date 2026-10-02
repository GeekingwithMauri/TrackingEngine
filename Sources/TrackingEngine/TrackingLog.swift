import AmplitudeSwift
import FirebaseAnalytics
import FirebaseCrashlytics
import TrackingEngineCore

struct TrackingLog: TrackingLoggable {
    /// `nil` when `setup` got no Amplitude key: Firebase stays the only analytics sink.
    let amplitude: Amplitude?

    init(
        amplitude: Amplitude? = nil
    ) {
        self.amplitude = amplitude
    }

    func log(
        errorName: String,
        parameters: [String: Any]
    ) {
        Crashlytics.crashlytics().log("\(errorName): \(parameters)")
    }

    /// Every event reaches both analytics sinks: the vendors' reports are read side by side
    /// while one history is still only in the other.
    func track(
        eventName: String,
        parameters: [String: Any]?
    ) {
        Analytics.logEvent(
            eventName,
            parameters: parameters
        )
        amplitude?.track(
            eventType: eventName,
            eventProperties: parameters
        )
    }

    func setCustomValue(
        _ value: String,
        forKey key: String
    ) {
        Crashlytics.crashlytics().setCustomValue(
            value,
            forKey: key
        )
    }

    func setUserProperty(
        _ value: String?,
        forName name: String
    ) {
        Analytics.setUserProperty(
            value,
            forName: name
        )
        guard let amplitude else { return }
        let identify = Identify()
        if let value {
            identify.set(
                property: name,
                value: value
            )
        } else {
            identify.unset(property: name)
        }
        amplitude.identify(identify: identify)
    }

    /// Every sink, from one call, deliberately: analytics answers "how many people", crash
    /// reporting answers "how many people hit this crash", and the second question is only
    /// answerable if it is keyed on the same id as the first.
    func setUserID(_ id: String?) {
        Analytics.setUserID(id)
        Crashlytics.crashlytics().setUserID(id)
        amplitude?.setUserId(userId: id)
    }
}
