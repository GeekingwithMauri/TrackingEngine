//
//  TrackingLog.swift
//  
//
//  Created by Mauricio Chirino on 27/3/22.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

protocol TrackingLoggable {
    /// Tracks user's events on the cloud provider. For the time being, that is **Firebase**
    /// - Parameters:
    ///   - eventName: event name to be tracked. I.e. _view_appeared_, _button_tapped_ and so forth
    ///   - parameters: The dictionary of event parameters. Passing `nil` indicates that the event has no parameters.
    func track(eventName: String, parameters: [String: Any]?)

    /// Tracks errors alongside its context on the cloud provider. For the time being, that is **Firebase**
    /// - Parameters:
    ///   - errorName: error name to be tracked.
    ///   - parameters: The dictionary of metadata context.
    func log(errorName: String, parameters: [String: Any])
}

struct TrackingLog: TrackingLoggable {
    func log(errorName: String, parameters: [String : Any]) {
        Crashlytics.crashlytics().log("\(errorName): \(parameters)")
    }

    func track(eventName: String, parameters: [String : Any]?) {
        Analytics.logEvent(eventName, parameters: parameters)
    }
}
