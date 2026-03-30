import XCTest
@testable import MultiViewStream

struct MockStreamProvider: StreamProviding {
    let streams: [StreamSource]

    func availableStreams() -> [StreamSource] {
        streams
    }
}

@MainActor
final class StreamPlayerManagerTests: XCTestCase {
    var manager: StreamPlayerManager!
    var mockProvider: MockStreamProvider!

    override func setUp() {
        super.setUp()
        manager = StreamPlayerManager()
        mockProvider = MockStreamProvider(streams: [
            StreamSource(title: "Stream 1", url: URL(string: "https://example.com/1.m3u8")!),
            StreamSource(title: "Stream 2", url: URL(string: "https://example.com/2.m3u8")!),
            StreamSource(title: "Stream 3", url: URL(string: "https://example.com/3.m3u8")!),
            StreamSource(title: "Stream 4", url: URL(string: "https://example.com/4.m3u8")!),
        ])
    }

    override func tearDown() {
        manager.stopAll()
        manager = nil
        mockProvider = nil
        super.tearDown()
    }

    func testLoadStreamsPopulatesSourcesAndStatuses() {
        manager.loadStreams(from: mockProvider)

        XCTAssertEqual(manager.activeStreams.count, 4)
        XCTAssertEqual(manager.statuses.count, 4)

        for source in manager.activeStreams {
            XCTAssertEqual(manager.statuses[source.id], .idle)
        }
    }

    func testLoadStreamsLimitsToMaxConcurrent() {
        let manyStreams = (0..<10).map {
            StreamSource(title: "Stream \($0)", url: URL(string: "https://example.com/\($0).m3u8")!)
        }
        let bigProvider = MockStreamProvider(streams: manyStreams)

        manager.loadStreams(from: bigProvider)

        XCTAssertEqual(manager.activeStreams.count, Constants.maxConcurrentStreams)
    }

    func testPrimaryStreamIDIsFirstAfterLoad() {
        manager.loadStreams(from: mockProvider)

        XCTAssertEqual(manager.primaryStreamID, manager.activeStreams.first?.id)
    }

    func testStartStreamCreatesPlayer() {
        manager.loadStreams(from: mockProvider)
        let source = manager.activeStreams[0]

        manager.startStream(source)

        XCTAssertNotNil(manager.player(for: source.id))
    }

    func testStopStreamRemovesPlayer() {
        manager.loadStreams(from: mockProvider)
        let source = manager.activeStreams[0]

        manager.startStream(source)
        XCTAssertNotNil(manager.player(for: source.id))

        manager.stopStream(source.id)
        XCTAssertNil(manager.player(for: source.id))
        XCTAssertEqual(manager.statuses[source.id], .idle)
    }

    func testStopAllClearsEverything() {
        manager.loadStreams(from: mockProvider)
        manager.startAllStreams()

        XCTAssertFalse(manager.players.isEmpty)

        manager.stopAll()

        XCTAssertTrue(manager.players.isEmpty)
        XCTAssertTrue(manager.activeStreams.isEmpty)
    }

    func testPromoteToPrimaryUpdatesBitrates() {
        manager.loadStreams(from: mockProvider)
        manager.startAllStreams()

        let secondStream = manager.activeStreams[1]
        manager.promoteToPrimary(secondStream.id, in: .primaryWithThumbnails)

        XCTAssertEqual(manager.primaryStreamID, secondStream.id)

        // Primary should have high bitrate
        let primaryItem = manager.player(for: secondStream.id)?.currentItem
        XCTAssertEqual(primaryItem?.preferredPeakBitRate, StreamConfiguration.primary.preferredPeakBitRate)

        // Others should have thumbnail bitrate
        for source in manager.activeStreams where source.id != secondStream.id {
            let item = manager.player(for: source.id)?.currentItem
            XCTAssertEqual(item?.preferredPeakBitRate, StreamConfiguration.thumbnail.preferredPeakBitRate)
        }
    }

    func testUnmuteOnlyMutesOthers() {
        manager.loadStreams(from: mockProvider)
        manager.startAllStreams()

        let target = manager.activeStreams[2]
        manager.unmuteOnly(target.id)

        for source in manager.activeStreams {
            let player = manager.player(for: source.id)
            if source.id == target.id {
                XCTAssertFalse(player?.isMuted ?? true)
            } else {
                XCTAssertTrue(player?.isMuted ?? false)
            }
        }
    }

    func testMemoryUsageReturnsNonZero() {
        let usage = manager.currentMemoryUsage()
        XCTAssertGreaterThan(usage, 0)
    }
}
