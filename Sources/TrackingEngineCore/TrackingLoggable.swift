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
}

extension TrackingLoggable {
    /// Default no-op, so this addition cannot break an existing conformer in
    /// another consumer of this package. A logger that has no crash reporter
    /// behind it simply has nothing to pin the value to.
    public func setCustomValue(
        _ value: String,
        forKey key: String
    ) {}
}
