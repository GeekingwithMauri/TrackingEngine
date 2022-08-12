# TrackingEngine
Tracking wrapper to preserve our codebase dependency-free from 3rd-party vendors.

## Rationale

Ideally, we want to have our code completely dependency-free and preserve control over its entire functioning. In the real world, we know this is unrealistic since it would imply reinventing the wheel over and over. 

_TrackingEngine_ centralizes the tracking SDKs and exposes them via facades.

## What's the point?
Contracts expire, SDKs get deprecated and fees rises. These, just to mention a few, are valid reasons to change tracking vendors. 

This is rather hard when our codebases are littered with direct SDKs implementations. _TrackingEngine_ makes such processes painless by making their consumption behind a facade. This why, whatever happens under the hood shall not concern our Tracking clients apps.

## Example of usage

```swift
// A recommended place to put it is on the application(_:didFinishLaunchingWithOptions:)` due to some vendor's inner workings (such as Firebase init swizzling)
func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ...
    // This is done before any logging occurs. 
    TrackingEngineFacade.setup()
    return true
}


// Tracking an event
TrackingEngineFacade.log(eventName: "view_appeared", parameters: ["type": "home"])
```

## Good practices recommendations
> “All problems in computer science can be solved by another level of indirection." - David Wheeler

And the end of the day, this is also a 3rd party dependency so it's recommemded to limit its own spreading.

In order to prevent the spread of `import TrackingEngine` and direct `TrackingEngineFacade.log` all over the place, it's highly advisable to centralize its usage within a thin wrapper as follows 👇🏽

```swift
import TrackingEngine

protocol TrackingLoggable {
    /// Tracks user's events via the `TrackingEngineFacade`
    /// - Parameters:
    ///   - eventName: event name to be tracked. I.e. _view_appeared_, _button_tapped_ and so forth
    ///   - parameters: The dictionary of event parameters. Passing `nil` indicates that the event has no parameters.
    func track(eventName: String, parameters: [String: Any]?)
}

struct Tracker: TrackingLoggable {
    func track(eventName: String, parameters: [String : Any]?) {
        TrackingEngineFacade.log(eventName: eventName, parameters: parameters)
    }
}
``` 

The above makes the library self contained. It also opens the door for testing, by simply replacing the real implementation with a `TrackingLoggable` with a [Spy](https://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs).
