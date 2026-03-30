import SwiftUI
import AVFoundation

struct FullscreenPlayerView: View {
    let source: StreamSource
    let player: AVPlayer?
    let status: StreamStatus
    @Binding var isPresented: Bool

    @State private var showControls = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                VideoPlayerView(player: player)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showControls.toggle()
                        }
                    }
            }

            if showControls {
                controlsOverlay
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 {
                        isPresented = false
                    }
                }
        )
        .statusBarHidden(true)
    }

    @ViewBuilder
    private var controlsOverlay: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
            }

            Spacer()

            HStack(spacing: 6) {
                statusIndicator
                Text(source.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch status {
        case .playing:
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)
        case .buffering, .loading:
            ProgressView()
                .scaleEffect(0.6)
        default:
            EmptyView()
        }
    }
}
