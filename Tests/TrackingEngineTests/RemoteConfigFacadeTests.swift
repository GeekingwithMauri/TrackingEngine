import XCTest
@testable import TrackingEngineCore

final class RemoteConfigFacadeTests: XCTestCase {
    override func tearDown() {
        RemoteConfigFacade.provider = nil
        super.tearDown()
    }

    func test_withNoProviderWired_everyFlagResolvesToItsCallerDefault() {
        // Given — a test host that links only TrackingEngineCore and never calls setup
        RemoteConfigFacade.provider = nil
        let sut = RemoteConfigFacade.self

        // Verify — both directions, so a hardcoded `false` can't pass this
        XCTAssertTrue(sut.isEnabled(
            "ff_anything",
            default: true
        ))
        XCTAssertFalse(sut.isEnabled(
            "ff_anything",
            default: false
        ))
    }

    func test_aWiredProviderAnswersInstead_andSeesTheDefaultItWasAskedWith() throws {
        // Given
        let resolverSpy = FlagResolvingSpy()
        resolverSpy.stubbedValues = ["ff_challengeUniversalLinks": true]
        let sut = RemoteConfigFacade.self
        sut.configure(with: resolverSpy)

        // When
        let enabled = sut.isEnabled(
            "ff_challengeUniversalLinks",
            default: false
        )

        // Verify — the default must reach the resolver, which is the only way it
        // can distinguish "console says false" from "console has never heard of this"
        XCTAssertTrue(
            enabled,
            "A wired provider must win over the baked-in default"
        )
        let asked = try XCTUnwrap(resolverSpy.invokedIsEnabledParameters)
        XCTAssertEqual(
            asked.key,
            "ff_challengeUniversalLinks"
        )
        XCTAssertFalse(asked.defaultValue)
    }

    func test_aProviderWithoutTheKey_fallsBackRatherThanInventingFalse() {
        // Given — the resolver knows nothing about this flag
        let sut = RemoteConfigFacade.self
        sut.configure(with: FlagResolvingSpy())

        // Verify — this is the whole failure mode `RemoteConfigResolver` guards
        // against with its `.static` source check
        XCTAssertTrue(sut.isEnabled(
            "ff_unknown",
            default: true
        ))
    }
}
