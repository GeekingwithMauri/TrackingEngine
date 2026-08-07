import FirebaseRemoteConfig
import XCTest

@testable import TrackingEngine
@testable import TrackingEngineCore

/// The source check is the whole of `resolution`, and getting it wrong is
/// invisible: every value still reads plausibly, it is only *why* that is
/// wrong. These pin all three sources explicitly.
final class RemoteConfigResolverTests: XCTestCase {
    func test_onlyAFetchedValueCountsAsAnAnswerFromTheConsole() {
        XCTAssertEqual(
            RemoteConfigResolver.resolution(
                source: .remote,
                value: true
            ),
            .remote(true)
        )
        XCTAssertEqual(
            RemoteConfigResolver.resolution(
                source: .remote,
                value: false
            ),
            .remote(false)
        )
    }

    func test_aSeededDefaultIsNotAnAnswer() {
        // `setup(defaults:)` seeds every one of the host's flags, so this is
        // the state of *every* key until a fetch lands — not an edge case.
        // Reporting it as `.remote` turns "never fetched" into "fetched and
        // off" across the board, and an experiment reading it would count
        // unassigned installs into its control arm.
        XCTAssertEqual(
            RemoteConfigResolver.resolution(
                source: .default,
                value: false
            ),
            .unavailable
        )
        XCTAssertEqual(
            RemoteConfigResolver.resolution(
                source: .default,
                value: true
            ),
            .unavailable
        )
    }

    func test_anUnknownKeyIsNotAnAnswerEither() {
        XCTAssertEqual(
            RemoteConfigResolver.resolution(
                source: .static,
                value: false
            ),
            .unavailable
        )
    }

    func test_theValueIsNotEvenReadUnlessItCameFromTheConsole() {
        // Given — `value` is an autoclosure, so a source that isn't `.remote`
        // must never evaluate it
        var didReadValue = false

        // When
        _ = RemoteConfigResolver.resolution(
            source: .default,
            value: {
                didReadValue = true

                return false
            }()
        )

        // Verify
        XCTAssertFalse(didReadValue)
    }
}
