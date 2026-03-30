import SwiftUI

@Observable
final class AppState {
    var currentLayout: StreamLayout = .grid2x2
    var primaryStreamIndex: Int = 0
    var showPerformanceOverlay: Bool = false
    var isFullscreen: Bool = false
    var fullscreenStreamIndex: Int = 0
}
