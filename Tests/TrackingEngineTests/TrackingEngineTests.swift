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
}
