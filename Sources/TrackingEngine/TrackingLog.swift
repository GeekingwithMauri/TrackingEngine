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
}
