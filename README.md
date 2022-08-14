# TrackingEngine

## Rationale

Ideally, we want to have our code completely dependency-free and preserve control over its entire functioning. In the real world, we know this is unrealistic since it would imply reinventing the wheel over and over. 

_TrackingEngine_ centralizes the tracking SDKs and exposes them via facades.

## What's the point?
Contracts expire, SDKs get deprecated and fees rises. These, just to mention a few, are valid reasons to change tracking vendors. 

This is rather hard when our codebases are littered with direct SDKs implementations. _TrackingEngine_ makes such processes painless by making their consumption behind a facade. This is why, whatever happens under the hood shall not concern our Tracking clients apps.

## Installation 
### Xcode 13
 1. From the **File** menu, **Add Packages…**.
 2. Enter package repository URL: `https://github.com/GeekingwithMauri/TrackingEngine`
 3. Confirm the version and let Xcode resolve the package

### Swift Package Manager

If you want to use _TrackingEngine_ in any other project that uses [SwiftPM](https://swift.org/package-manager/), add the package as a dependency in `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/GeekingwithMauri/TrackingEngine",
    from: "0.1.0"
  ),
]
```

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

And the end of the day, this is also a 3rd party dependency so it's recommended to limit its own spreading.

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
## Testing 

The above recommendation makes the library self contained. It also opens the door for testing, by simply replacing the real implementation with a `TrackingLoggable` with a [Spy](https://github.com/GeekingwithMauri/TrackingEngine/blob/main/Tests/TrackingEngineTests/TrackingLoggableSpy.swift).

Check out [the example](https://github.com/GeekingwithMauri/TrackingEngine/blob/main/Tests/TrackingEngineTests/TrackingEngineTests.swift) of how said testing could occur.

## Current limitations
- For the time being, this only supports Firebase. 
- `GoogleService-Info` must be included in the main project
