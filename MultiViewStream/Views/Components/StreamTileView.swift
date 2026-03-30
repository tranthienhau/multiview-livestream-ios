import SwiftUI
import AVFoundation

struct StreamTileView: View {
    let source: StreamSource
    let player: AVPlayer?
    let status: StreamStatus
    let isPrimary: Bool
    let namespace: Namespace.ID

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Video layer
            if let player {
                VideoPlayerView(player: player)
                    .matchedGeometryEffect(id: source.id, in: namespace)
            } else {
                Color.black
                    .matchedGeometryEffect(id: source.id, in: namespace)
            }

            // Status overlay
            overlayContent
        }
        .clipShape(RoundedRectangle(cornerRadius: isPrimary ? 12 : 8))
        .shadow(color: .black.opacity(0.3), radius: isPrimary ? 8 : 4)
    }

    @ViewBuilder
    private var overlayContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer()

            HStack(spacing: 6) {
                // Status badge
                statusBadge

                Text(source.title)
                    .font(isPrimary ? .subheadline.bold() : .caption2)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Spacer()

                if isPrimary {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .playing:
            HStack(spacing: 4) {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)
                Text("LIVE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color.red.opacity(0.85))
            .clipShape(Capsule())
        case .loading, .buffering:
            ProgressView()
                .scaleEffect(0.5)
                .frame(width: 12, height: 12)
        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption2)
                .foregroundStyle(.yellow)
        case .paused:
            Image(systemName: "pause.circle.fill")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
        case .idle:
            EmptyView()
        }
    }
}
