import XCTest
@testable import MultiViewStream

final class StreamLayoutTests: XCTestCase {
    let testSize = CGSize(width: 400, height: 600)

    // MARK: - Grid 2x2

    func testGrid2x2FourItems() {
        let frames = StreamLayout.grid2x2.frames(in: testSize, count: 4, primaryIndex: 0)

        XCTAssertEqual(frames.count, 4)

        // All tiles should have positive dimensions
        for frame in frames {
            XCTAssertGreaterThan(frame.width, 0)
            XCTAssertGreaterThan(frame.height, 0)
        }

        // Tiles should not overlap significantly
        XCTAssertLessThan(frames[0].x + frames[0].width, frames[1].x + 1) // 0 is left of 1
        XCTAssertLessThan(frames[0].y + frames[0].height, frames[2].y + 1) // 0 is above 2
    }

    func testGrid2x2SingleItem() {
        let frames = StreamLayout.grid2x2.frames(in: testSize, count: 1, primaryIndex: 0)

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(frames[0].width, testSize.width)
        XCTAssertEqual(frames[0].height, testSize.height)
    }

    func testGrid2x2TwoItems() {
        let frames = StreamLayout.grid2x2.frames(in: testSize, count: 2, primaryIndex: 0)

        XCTAssertEqual(frames.count, 2)
        // Should be side by side in one row
        XCTAssertEqual(frames[0].y, frames[1].y)
    }

    // MARK: - Primary with Thumbnails

    func testPrimaryWithThumbnailsFourItems() {
        let frames = StreamLayout.primaryWithThumbnails.frames(in: testSize, count: 4, primaryIndex: 0)

        XCTAssertEqual(frames.count, 4)

        // Primary should be larger than thumbnails
        let primaryArea = frames[0].width * frames[0].height
        for i in 1..<4 {
            let thumbArea = frames[i].width * frames[i].height
            XCTAssertGreaterThan(primaryArea, thumbArea)
        }

        // Primary should span full width
        XCTAssertEqual(frames[0].width, testSize.width)
    }

    func testPrimaryWithThumbnailsSingleItem() {
        let frames = StreamLayout.primaryWithThumbnails.frames(in: testSize, count: 1, primaryIndex: 0)

        XCTAssertEqual(frames.count, 1)
        XCTAssertEqual(frames[0].width, testSize.width)
        XCTAssertEqual(frames[0].height, testSize.height)
    }

    func testPrimaryWithThumbnailsDifferentPrimaryIndex() {
        let frames = StreamLayout.primaryWithThumbnails.frames(in: testSize, count: 4, primaryIndex: 2)

        XCTAssertEqual(frames.count, 4)

        // Index 2 should be the primary (full width, largest)
        XCTAssertEqual(frames[2].width, testSize.width)
        XCTAssertGreaterThan(frames[2].height, frames[0].height)
    }

    // MARK: - Side by Side

    func testSideBySideTwoItems() {
        let frames = StreamLayout.sideBySide.frames(in: testSize, count: 2, primaryIndex: 0)

        XCTAssertEqual(frames.count, 2)

        // Both should have same height (full)
        XCTAssertEqual(frames[0].height, testSize.height)
        XCTAssertEqual(frames[1].height, testSize.height)

        // Side by side
        XCTAssertLessThan(frames[0].x + frames[0].width, frames[1].x + 1)
    }

    func testSideBySideExtraStreamsHidden() {
        let frames = StreamLayout.sideBySide.frames(in: testSize, count: 4, primaryIndex: 0)

        XCTAssertEqual(frames.count, 4)

        // Third and fourth should be zero-sized
        XCTAssertEqual(frames[2].width, 0)
        XCTAssertEqual(frames[2].height, 0)
        XCTAssertEqual(frames[3].width, 0)
        XCTAssertEqual(frames[3].height, 0)
    }

    // MARK: - Edge Cases

    func testEmptyCountReturnsEmpty() {
        for layout in StreamLayout.allCases {
            let frames = layout.frames(in: testSize, count: 0, primaryIndex: 0)
            XCTAssertTrue(frames.isEmpty)
        }
    }
}
