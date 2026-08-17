import FirebaseAnalytics
import FirebaseCrashlytics
import TrackingEngineCore

struct TrackingLog: TrackingLoggable {
    func log(
        errorName: String,
        parameters: [String: Any]
    ) {
        Crashlytics.crashlytics().log("\(errorName): \(parameters)")
    }

    func track(
        eventName: String,
        parameters: [String: Any]?
    ) {
        Analytics.logEvent(
            eventName,
            parameters: parameters
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
    }

    /// Both sinks, from one call, deliberately: analytics answers "how many people", crash
    /// reporting answers "how many people hit this crash", and the second question is only
    /// answerable if it is keyed on the same id as the first.
    func setUserID(_ id: String?) {
        Analytics.setUserID(id)
        Crashlytics.crashlytics().setUserID(id)
    }
}
