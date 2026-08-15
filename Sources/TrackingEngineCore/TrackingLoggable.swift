public protocol TrackingLoggable {
    func track(
        eventName: String,
        parameters: [String: Any]?
    )
    func log(
        errorName: String,
        parameters: [String: Any]
    )

    /// Pins a key/value onto every *subsequent* crash report, so issues can be
    /// sliced by it in the console instead of diagnosed blind. Unlike `track`
    /// and `log` this is state, not an event: it says what this install *is*,
    /// not what it did.
    func setCustomValue(
        _ value: String,
        forKey key: String
    )

    /// Pins a key/value onto every *subsequent* analytics event **and** the user record
    /// behind it, so audiences, Remote Config conditions and A/B test exclusions can be
    /// keyed on it. Like `setCustomValue` this is state rather than an event.
    ///
    /// ⚠️ It is **not retroactive within a session**: events already queued when it is
    /// called — `first_open` and the first `session_start` — land untagged.
    func setUserProperty(
        _ value: String?,
        forName name: String
    )
}

extension TrackingLoggable {
    /// Default no-op, so this addition cannot break an existing conformer in
    /// another consumer of this package. A logger that has no crash reporter
    /// behind it simply has nothing to pin the value to.
    public func setCustomValue(
        _ value: String,
        forKey key: String
    ) {}

    /// Default no-op, for the same reason as `setCustomValue` above.
    public func setUserProperty(
        _ value: String?,
        forName name: String
    ) {}
}
