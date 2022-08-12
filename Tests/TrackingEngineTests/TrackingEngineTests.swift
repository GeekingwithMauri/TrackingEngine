import XCTest
@testable import TrackingEngine

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
        sut.log(eventName: stubbedEventName, parameters: [stubbedKeyParameter: stubbedValueParameter])
        let logged = try XCTUnwrap(trackerSpy.invokedTrackParameters)
        let loggedData = try XCTUnwrap(logged.parameters)

        // Verify
        XCTAssertEqual(logged.eventName, stubbedEventName, "Event name isn't being logged properly")
        XCTAssertEqual(loggedData.keys.first!, stubbedKeyParameter, "Event key isn't being logged properly")
        XCTAssertEqual(loggedData.values.first as! String,
                       stubbedValueParameter,
                       "Event value isn't being logged properly")
    }
}
