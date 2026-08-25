import XCTest

@testable import TrackingEngine
@testable import TrackingEngineCore

/// Traits decide which installs a console condition can single out, and every
/// way of getting this wrong is silent: the fetch still succeeds, the flags
/// still resolve, and only the targeting quietly matches nobody — or, worse, the
/// flags stop arriving because a rejected trait took the fetch down with it.
final class RemoteConfigTraitsTests: XCTestCase {
    func test_withNoTraits_theFetchHappensSynchronouslyAndNothingIsPublished() {
        // Given — every caller that predates the `traits` parameter
        var didSetSignals = false
        var didFetch = false

        // When
        RemoteConfigFacade.publish(
            traits: [:],
            setting: { _ in didSetSignals = true },
            thenFetching: { didFetch = true }
        )

        // Verify — asserted immediately, with no expectation and no awaiting:
        // that is the assertion. An empty bag must not push the flag fetch
        // behind a suspension point at every launch.
        XCTAssertTrue(
            didFetch,
            "The fetch must still be synchronous for callers passing no traits"
        )
        XCTAssertFalse(
            didSetSignals,
            "Publishing an empty bag is a round-trip for nothing"
        )
    }

    func test_traitsArePublishedBeforeTheFetch_andReachThePublisherVerbatim() {
        // Given
        let traits = [
            "install_id": "ABCDEF01-2345-4678-9ABC-DEF012345678",
            "distribution": "testflight"
        ]
        var published: [String: String]?
        // A recorded *sequence*, not a pair of flags. Two flags read after the
        // fact are last-write-wins: a double fetch sets "did publish happen
        // first?" to false and then true, and the assertion sees only the
        // second. Asserting the whole sequence catches the order and the
        // duplicate with one comparison — and this test genuinely passed
        // against a double-fetching implementation before it was written this
        // way.
        var events = [String]()
        let fetched = expectation(description: "fetch")

        // When
        RemoteConfigFacade.publish(
            traits: traits,
            setting: {
                published = $0
                events.append("publish")
            },
            thenFetching: {
                events.append("fetch")
                fetched.fulfill()
            }
        )

        // Verify
        wait(
            for: [fetched],
            timeout: 1
        )
        XCTAssertEqual(
            events,
            ["publish", "fetch"],
            "Conditions are evaluated against the traits held at fetch time — publishing "
                + "after it means the first fetch misses them entirely, and fetching twice "
                + "spends a second round-trip to correct the first"
        )
        XCTAssertEqual(
            published,
            traits,
            "A condition matches the whole value; nothing may be trimmed, renamed or dropped"
        )
    }

    func test_aRejectedTraitStillLetsTheFlagsThrough() {
        // Given — what the SDK does to an over-long value or an over-full batch
        let fetched = expectation(description: "fetch")

        // When
        RemoteConfigFacade.publish(
            traits: ["install_id": String(
                repeating: "x",
                count: 501
            )],
            setting: { _ in throw TraitError.rejected },
            thenFetching: { fetched.fulfill() }
        )

        // Verify — the whole point. Targeting is lost, the kill switches are not.
        wait(
            for: [fetched],
            timeout: 1
        )
    }
}

private enum TraitError: Error {
    case rejected
}
