import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var playerManager = StreamPlayerManager()
    @State private var performanceMonitor = PerformanceMonitor()
    @State private var showFullscreen = false
    @Namespace private var streamNamespace

    private let provider: StreamProviding = HLSStreamProvider()

    var body: some View {
        @Bindable var state = appState

        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Layout toolbar
                    layoutToolbar
                        .padding(.horizontal)
                        .padding(.top, 4)

                    // Stream grid
                    MultiStreamGridView(
                        sources: playerManager.activeStreams,
                        playerManager: playerManager,
                        layout: appState.currentLayout,
                        primaryIndex: appState.primaryStreamIndex,
                        namespace: streamNamespace,
                        onTileTap: handleTileTap
                    )
                    .padding(8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.currentLayout)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: appState.primaryStreamIndex)
                }

                // Performance overlay
                if appState.showPerformanceOverlay {
                    PerformanceOverlayView(
                        fps: performanceMonitor.fps,
                        memoryMB: performanceMonitor.memoryMB
                    )
                    .padding(.trailing, 12)
                    .padding(.top, 4)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("MultiView Stream")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Klic.gg Style Multi-Cam")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            appState.showPerformanceOverlay.toggle()
                        } label: {
                            Label(
                                appState.showPerformanceOverlay ? "Hide Stats" : "Show Stats",
                                systemImage: "gauge.with.dots.needle.bottom.50percent"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            playerManager.loadStreams(from: provider)
            playerManager.startAllStreams()
        }
        .onDisappear {
            playerManager.stopAll()
            performanceMonitor.stop()
        }
        .onChange(of: appState.showPerformanceOverlay) { _, newValue in
            if newValue {
                performanceMonitor.start()
            } else {
                performanceMonitor.stop()
            }
        }
        .fullScreenCover(isPresented: $showFullscreen) {
            let idx = appState.fullscreenStreamIndex
            let streams = playerManager.activeStreams
            if idx < streams.count {
                FullscreenPlayerView(
                    source: streams[idx],
                    player: playerManager.player(for: streams[idx].id),
                    status: playerManager.statuses[streams[idx].id] ?? .idle,
                    isPresented: $showFullscreen
                )
            }
        }
    }

    // MARK: - Layout Toolbar

    private var layoutToolbar: some View {
        HStack(spacing: 12) {
            ForEach(StreamLayout.allCases, id: \.self) { layout in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        appState.currentLayout = layout
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: layout.sfSymbol)
                            .font(.system(size: 18))
                        Text(layout.displayName)
                            .font(.system(size: 9))
                    }
                    .foregroundStyle(appState.currentLayout == layout ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(appState.currentLayout == layout ? Color.white.opacity(0.15) : .clear)
                    )
                }
            }
        }
    }

    // MARK: - Actions

    private func handleTileTap(_ index: Int) {
        let streams = playerManager.activeStreams
        guard index < streams.count else { return }

        switch appState.currentLayout {
        case .grid2x2:
            // Tap promotes to primary+thumbnails
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appState.primaryStreamIndex = index
                appState.currentLayout = .primaryWithThumbnails
            }
            playerManager.promoteToPrimary(streams[index].id, in: .primaryWithThumbnails)
            playerManager.unmuteOnly(streams[index].id)

        case .primaryWithThumbnails:
            if index == appState.primaryStreamIndex {
                // Tap on primary goes fullscreen
                appState.fullscreenStreamIndex = index
                showFullscreen = true
            } else {
                // Tap on thumbnail promotes it
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appState.primaryStreamIndex = index
                }
                playerManager.promoteToPrimary(streams[index].id, in: .primaryWithThumbnails)
                playerManager.unmuteOnly(streams[index].id)
            }

        case .sideBySide:
            // Tap to go fullscreen
            appState.fullscreenStreamIndex = index
            showFullscreen = true
        }
    }
}
