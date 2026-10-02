import AmplitudeSwift
import Firebase
import FirebaseAnalytics
import TrackingEngineCore

extension TrackingEngineFacade {
    /// - Parameter forcingAnalyticsCollection: `nil` leaves collection to
    ///   `FIREBASE_ANALYTICS_COLLECTION_ENABLED` in the app's `Info.plist`, which is the
    ///   shipping answer. A non-`nil` value writes Firebase's **persisted** runtime override.
    ///
    ///   That override survives relaunches, which is why the caller passes a `Bool` rather
    ///   than only opting in: a build that opts in once and is then launched without the
    ///   argument must go quiet again, and only an explicit `false` does that.
    ///
    /// - Parameter amplitudeAPIKey: adds Amplitude as a second analytics sink for every
    ///   `log(eventName:)`, `setUserProperty` and `setUserID`. `nil` or empty keeps Firebase
    ///   alone, which is what every existing caller gets. Amplitude has no plist switch, so
    ///   `forcingAnalyticsCollection == false` opts it out for the launch; the caller decides
    ///   which key, if any, a build carries.
    public static func setup(
        forcingAnalyticsCollection: Bool? = nil,
        amplitudeAPIKey: String? = nil
    ) {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        if let forcingAnalyticsCollection {
            Analytics.setAnalyticsCollectionEnabled(forcingAnalyticsCollection)
        }
        var amplitude: Amplitude?
        if let amplitudeAPIKey, !amplitudeAPIKey.isEmpty {
            amplitude = Amplitude(
                configuration: Configuration(
                    apiKey: amplitudeAPIKey,
                    optOut: forcingAnalyticsCollection == false
                )
            )
        }
        configure(with: TrackingLog(amplitude: amplitude))
    }
}
