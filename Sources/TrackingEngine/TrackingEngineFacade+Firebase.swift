import Firebase
import TrackingEngineCore

extension TrackingEngineFacade {
    public static func setup() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        configure(with: TrackingLog())
    }
}
