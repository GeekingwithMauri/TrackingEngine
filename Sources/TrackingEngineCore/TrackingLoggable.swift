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

    /// Identifies *who* every subsequent analytics event and crash report belongs to, so
    /// counts and cohorts are computed per person rather than per install. Like
    /// `setCustomValue` and `setUserProperty` this is state, not an event.
    ///
    /// **One call reaches every sink a conformer has.** An id that is set in one console
    /// and missing in another is worse than no id at all: the two disagree and neither is
    /// obviously wrong. A caller that has to remember a second call is one that will make
    /// half of them.
    ///
    /// The library neither mints nor stores the value — **durability is the caller's
    /// problem.** An id that is regenerated per install identifies an install, and passing
    /// one here buys nothing.
    ///
    /// ⚠️ Not retroactive, within a session or across history: events already queued when
    /// it is called land unattributed, and events recorded before it first shipped are
    /// never re-labelled.
    ///
    /// - Parameter id: `nil` clears the identity, which is how a conformer forgets a user.
    func setUserID(_ id: String?)
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

    /// Default no-op, for the same reason as `setCustomValue` above. A conformer with no
    /// user-scoped sink behind it has nobody to attribute anything to.
    public func setUserID(_ id: String?) {}
}
