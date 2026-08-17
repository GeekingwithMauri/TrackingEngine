import XCTest
@testable import TrackingEngineCore

final class TrackingEngineTests: XCTestCase {
    func test_trackingEngineFacadeIsLoggingProperly() throws {
        // Given
        let stubbedEventName = "dummyEvent"
        let stubbedKeyParameter = "viewAppeared"
        let stubbedValueParameter = "dummyView"
        let trackerSpy = TrackingLoggableSpy()
        let sut = TrackingEngineFacade.self
        sut.logger = trackerSpy

        // When
        sut.log(
            eventName: stubbedEventName,
            parameters: [stubbedKeyParameter: stubbedValueParameter]
        )
        let logged = try XCTUnwrap(trackerSpy.invokedTrackParameters)
        let loggedData = try XCTUnwrap(logged.parameters)

        // Verify
        XCTAssertEqual(
            logged.eventName,
            stubbedEventName,
            "Event name isn't being logged properly"
        )
        XCTAssertEqual(
            loggedData.keys.first!,
            stubbedKeyParameter,
            "Event key isn't being logged properly"
        )
        XCTAssertEqual(
            loggedData.values.first as! String,
            stubbedValueParameter,
            "Event value isn't being logged properly"
        )
    }

    func test_trackingEngineFacadeIsLoggingCrashesProperly() throws {
        // Given
        let stubbedErrorName = "dummyCrash"
        let stubbedKeyParameter = "expectedParameter"
        let stubbedValueParameter = "failingValue"
        let trackerSpy = TrackingLoggableSpy()
        let sut = TrackingEngineFacade.self
        sut.logger = trackerSpy

        // When
        sut.log(
            errorName: stubbedErrorName,
            parameters: [stubbedKeyParameter: stubbedValueParameter]
        )
        let logged = try XCTUnwrap(trackerSpy.invokedLogParameters)
        let loggedData = try XCTUnwrap(logged.parameters)

        // Verify
        XCTAssertEqual(
            logged.errorName,
            stubbedErrorName,
            "Event name isn't being logged properly"
        )
        XCTAssertEqual(
            loggedData.keys.first!,
            stubbedKeyParameter,
            "Event key isn't being logged properly"
        )
        XCTAssertEqual(
            loggedData.values.first as! String,
            stubbedValueParameter,
            "Event value isn't being logged properly"
        )
    }

    func test_trackingEngineFacadeForwardsCustomValuesToTheLogger() throws {
        // Given
        let trackerSpy = TrackingLoggableSpy()
        let sut = TrackingEngineFacade.self
        sut.logger = trackerSpy

        // When
        sut.setCustomValue(
            "revamp",
            forKey: "arm"
        )
        let recorded = try XCTUnwrap(trackerSpy.invokedSetCustomValueParameters)

        // Verify — crash-report metadata is state, not an event, so it must
        // reach the logger verbatim and exactly once
        XCTAssertEqual(
            recorded.value,
            "revamp"
        )
        XCTAssertEqual(
            recorded.key,
            "arm"
        )
        XCTAssertEqual(
            trackerSpy.invokedSetCustomValueCount,
            1
        )
    }

    func test_trackingEngineFacadeForwardsTheUserIdentityToTheLogger() throws {
        // Given
        let trackerSpy = TrackingLoggableSpy()
        let sut = TrackingEngineFacade.self
        sut.logger = trackerSpy

        // When
        sut.setUserID("57C8D2E4-0000-4B1A-9E3F-000000000001")

        // Verify — verbatim and exactly once: an id the facade edits, truncates or
        // re-sends is an id that no longer matches the one the caller can be asked for
        XCTAssertEqual(
            try XCTUnwrap(trackerSpy.invokedSetUserIDParameter),
            "57C8D2E4-0000-4B1A-9E3F-000000000001"
        )
        XCTAssertEqual(
            trackerSpy.invokedSetUserIDCount,
            1
        )
    }

    func test_trackingEngineFacadeForwardsAClearedUserIdentity() throws {
        // Given
        let trackerSpy = TrackingLoggableSpy()
        let sut = TrackingEngineFacade.self
        sut.logger = trackerSpy

        // When
        sut.setUserID(nil)

        // Verify — the negative control. `nil` is how a conformer forgets a user, so it
        // has to travel rather than be swallowed as "nothing to do"
        XCTAssertEqual(
            trackerSpy.invokedSetUserIDCount,
            1
        )
        XCTAssertNil(
            try XCTUnwrap(trackerSpy.invokedSetUserIDParameter)
        )
    }

    func test_aBareConformerCompilesAndItsDefaultsAreInert() {
        // Given a conformer that implements only the two required members
        let sut = BareTrackingLoggable()

        // When — every optional member is reachable through the default extension
        sut.setUserID("ignored")
        sut.setUserProperty(
            "ignored",
            forName: "ignored"
        )
        sut.setCustomValue(
            "ignored",
            forKey: "ignored"
        )

        // Verify — the compile is half the pin; the other half is that no default
        // quietly routes itself into a required member behind the conformer's back
        XCTAssertFalse(
            sut.recordedSomething,
            "A no-op default reached `track` or `log`"
        )
    }
}
