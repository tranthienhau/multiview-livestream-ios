import Foundation

enum StreamLayout: String, CaseIterable, Sendable {
    case grid2x2
    case primaryWithThumbnails
    case sideBySide

    var displayName: String {
        switch self {
        case .grid2x2: return "2x2 Grid"
        case .primaryWithThumbnails: return "Primary + Thumbnails"
        case .sideBySide: return "Side by Side"
        }
    }

    var sfSymbol: String {
        switch self {
        case .grid2x2: return "square.grid.2x2"
        case .primaryWithThumbnails: return "rectangle.grid.1x2"
        case .sideBySide: return "rectangle.split.2x1"
        }
    }

    struct TileFrame: Equatable, Sendable {
        let x: CGFloat
        let y: CGFloat
        let width: CGFloat
        let height: CGFloat
    }

    func frames(in size: CGSize, count: Int, primaryIndex: Int) -> [TileFrame] {
        guard count > 0 else { return [] }
        let spacing: CGFloat = 4

        switch self {
        case .grid2x2:
            return grid2x2Frames(in: size, count: count, spacing: spacing)
        case .primaryWithThumbnails:
            return primaryWithThumbnailsFrames(in: size, count: count, primaryIndex: primaryIndex, spacing: spacing)
        case .sideBySide:
            return sideBySideFrames(in: size, count: count, spacing: spacing)
        }
    }

    private func grid2x2Frames(in size: CGSize, count: Int, spacing: CGFloat) -> [TileFrame] {
        let cols = count <= 1 ? 1 : 2
        let rows = count <= 2 ? 1 : 2
        let tileW = (size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols)
        let tileH = (size.height - spacing * CGFloat(rows - 1)) / CGFloat(rows)

        var frames: [TileFrame] = []
        for i in 0..<count {
            let col = i % 2
            let row = i / 2
            frames.append(TileFrame(
                x: CGFloat(col) * (tileW + spacing),
                y: CGFloat(row) * (tileH + spacing),
                width: tileW,
                height: tileH
            ))
        }
        return frames
    }

    private func primaryWithThumbnailsFrames(in size: CGSize, count: Int, primaryIndex: Int, spacing: CGFloat) -> [TileFrame] {
        guard count > 1 else {
            return [TileFrame(x: 0, y: 0, width: size.width, height: size.height)]
        }

        let thumbnailCount = count - 1
        let thumbnailHeight = (size.height - spacing) * 0.25
        let primaryHeight = size.height - thumbnailHeight - spacing
        let thumbnailWidth = (size.width - spacing * CGFloat(thumbnailCount - 1)) / CGFloat(thumbnailCount)

        var frames = [TileFrame](repeating: TileFrame(x: 0, y: 0, width: 0, height: 0), count: count)

        frames[primaryIndex] = TileFrame(
            x: 0,
            y: 0,
            width: size.width,
            height: primaryHeight
        )

        var thumbIdx = 0
        for i in 0..<count where i != primaryIndex {
            frames[i] = TileFrame(
                x: CGFloat(thumbIdx) * (thumbnailWidth + spacing),
                y: primaryHeight + spacing,
                width: thumbnailWidth,
                height: thumbnailHeight
            )
            thumbIdx += 1
        }
        return frames
    }

    private func sideBySideFrames(in size: CGSize, count: Int, spacing: CGFloat) -> [TileFrame] {
        let effectiveCount = min(count, 2)
        let tileW = (size.width - spacing * CGFloat(effectiveCount - 1)) / CGFloat(effectiveCount)

        var frames: [TileFrame] = []
        for i in 0..<count {
            if i < 2 {
                frames.append(TileFrame(
                    x: CGFloat(i) * (tileW + spacing),
                    y: 0,
                    width: tileW,
                    height: size.height
                ))
            } else {
                // Extra streams hidden in side-by-side
                frames.append(TileFrame(x: 0, y: 0, width: 0, height: 0))
            }
        }
        return frames
    }
}
