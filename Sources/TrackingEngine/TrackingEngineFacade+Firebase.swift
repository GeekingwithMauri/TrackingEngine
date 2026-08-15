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
    public static func setup(
        forcingAnalyticsCollection: Bool? = nil
    ) {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        if let forcingAnalyticsCollection {
            Analytics.setAnalyticsCollectionEnabled(forcingAnalyticsCollection)
        }
        configure(with: TrackingLog())
    }
}
