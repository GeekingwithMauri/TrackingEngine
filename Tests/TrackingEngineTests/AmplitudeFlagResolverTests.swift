import Experiment
import XCTest

@testable import TrackingEngine
@testable import TrackingEngineCore

/// The variant → resolution mapping is the whole of the Amplitude resolver, and every
/// wrong answer still reads plausibly: a kill switch that cannot kill, or an unassigned
/// install counted into an arm.
final class AmplitudeFlagResolverTests: XCTestCase {
    func test_anAssignedVariantIsOn_unlessItNamesTheBaseline() {
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: Variant("on")),
            .remote(true)
        )
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: Variant("treatment")),
            .remote(true)
        )
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: Variant("control")),
            .remote(false)
        )
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: Variant("off")),
            .remote(false)
        )
    }

    func test_theDefaultVariantIsTheConsoleSayingOff_notSilence() {
        // Given — what `/sdk/v2/vardata?v=0` returns for a flag this install is not in:
        // no value, key `off`, `metadata.default`
        let served = Variant(
            nil,
            payload: nil,
            expKey: nil,
            key: "off",
            metadata: ["default": true]
        )

        // Verify — a kill switch flipped off in the console must read `false`; `.unavailable`
        // would hand the caller its baked-in default, which for a kill switch is `true`
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: served),
            .remote(false)
        )
    }

    func test_anEmptyVariantIsNotAnAnswer() {
        // Given — nothing fetched, the fetch failed, or the key is not in the deployment
        XCTAssertEqual(
            AmplitudeFlagResolver.resolution(of: Variant()),
            .unavailable
        )
    }

    func test_isEnabledFallsBackOnlyWhenThereIsNoAnswer() {
        // Given
        let client = ExperimentClientStub(variants: [
            "ff_on": Variant("on"),
            "ff_off": Variant(
                nil,
                payload: nil,
                expKey: nil,
                key: "off",
                metadata: ["default": true]
            ),
        ])
        let sut = AmplitudeFlagResolver(client: client)

        // Verify
        XCTAssertTrue(sut.isEnabled(
            "ff_on",
            default: false
        ))
        XCTAssertFalse(sut.isEnabled(
            "ff_off",
            default: true
        ))
        XCTAssertTrue(sut.isEnabled(
            "ff_unknown",
            default: true
        ))
        XCTAssertEqual(
            client.askedKeys,
            ["ff_on", "ff_off", "ff_unknown"]
        )
    }
}

/// Only `variant(_:)` matters here; the rest is the protocol's floor.
private final class ExperimentClientStub: ExperimentClient {
    let variants: [String: Variant]
    private(set) var askedKeys = [String]()

    init(variants: [String: Variant]) {
        self.variants = variants
    }

    func variant(_ key: String) -> Variant {
        variant(
            key,
            fallback: nil
        )
    }

    func variant(
        _ key: String,
        fallback: Variant?
    ) -> Variant {
        askedKeys.append(key)

        return variants[key] ?? fallback ?? Variant()
    }

    func start(
        _ user: ExperimentUser?,
        completion: ((Error?) -> Void)?
    ) {}
    func stop() {}
    func fetch(
        user: ExperimentUser?,
        completion: ((ExperimentClient, Error?) -> Void)?
    ) {}
    func fetch(
        user: ExperimentUser?,
        options: FetchOptions?,
        completion: ((ExperimentClient, Error?) -> Void)?
    ) {}
    func all() -> [String: Variant] { variants }
    func exposure(key: String) {}
    func setUser(_ user: ExperimentUser?) {}
    func getUser() -> ExperimentUser? { nil }
    func clear() {}
    func setTracksAssignment(_ track: Bool) {}
    func getUserProvider() -> ExperimentUserProvider? { nil }
    func setUserProvider(_ userProvider: ExperimentUserProvider) -> ExperimentClient { self }
}
