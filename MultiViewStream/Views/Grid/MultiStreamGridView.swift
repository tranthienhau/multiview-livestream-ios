import SwiftUI

struct MultiStreamGridView: View {
    let sources: [StreamSource]
    let playerManager: StreamPlayerManager
    let layout: StreamLayout
    let primaryIndex: Int
    let namespace: Namespace.ID
    let onTileTap: (Int) -> Void

    var body: some View {
        GeometryReader { geometry in
            let frames = layout.frames(
                in: geometry.size,
                count: sources.count,
                primaryIndex: primaryIndex
            )

            ZStack(alignment: .topLeading) {
                ForEach(Array(sources.enumerated()), id: \.element.id) { index, source in
                    let frame = index < frames.count ? frames[index] : StreamLayout.TileFrame(x: 0, y: 0, width: 0, height: 0)

                    if frame.width > 0 && frame.height > 0 {
                        StreamTileView(
                            source: source,
                            player: playerManager.player(for: source.id),
                            status: playerManager.statuses[source.id] ?? .idle,
                            isPrimary: index == primaryIndex && layout == .primaryWithThumbnails,
                            namespace: namespace
                        )
                        .frame(width: frame.width, height: frame.height)
                        .offset(x: frame.x, y: frame.y)
                        .onTapGesture {
                            onTileTap(index)
                        }
                    }
                }
            }
        }
    }
}
