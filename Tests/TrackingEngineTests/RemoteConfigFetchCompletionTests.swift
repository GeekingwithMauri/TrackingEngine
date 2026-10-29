import XCTest

@testable import TrackingEngine
@testable import TrackingEngineCore

final class RemoteConfigFetchCompletionTests: XCTestCase {
    private let spy = TrackingLoggableSpy()

    override func setUp() {
        super.setUp()
        TrackingEngineFacade.configure(with: spy)
    }

    func test_successCallsTheCallbackOnce_andLogsNothing() {
        // Given
        let calls = Counter()

        // When
        RemoteConfigFacade.completeFetch(
            error: nil,
            onFetched: { calls.increment() }
        )

        // Verify
        XCTAssertEqual(
            calls.value,
            1
        )
        XCTAssertEqual(
            spy.invokedLogCount,
            0
        )
    }

    func test_errorSkipsTheCallback_andStillLogs() {
        // Given
        let calls = Counter()

        // When
        RemoteConfigFacade.completeFetch(
            error: FetchError.offline,
            onFetched: { calls.increment() }
        )

        // Verify
        XCTAssertEqual(
            calls.value,
            0
        )
        XCTAssertEqual(
            spy.invokedLogParameters?.errorName,
            "remoteConfigFetchFailed"
        )
    }

    func test_aNilCallbackIsANoOp_onSuccessAndOnError() {
        // When
        RemoteConfigFacade.completeFetch(
            error: nil,
            onFetched: nil
        )
        RemoteConfigFacade.completeFetch(
            error: FetchError.offline,
            onFetched: nil
        )

        // Verify — nothing crashed, and only the error logged
        XCTAssertEqual(
            spy.invokedLogCount,
            1
        )
    }
}

private enum FetchError: Error {
    case offline
}

private final class Counter: @unchecked Sendable {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
