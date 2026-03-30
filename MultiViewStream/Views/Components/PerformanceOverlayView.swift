import SwiftUI

struct PerformanceOverlayView: View {
    let fps: Double
    let memoryMB: Double

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack(spacing: 4) {
                Circle()
                    .fill(fpsColor)
                    .frame(width: 8, height: 8)
                Text("\(Int(fps)) FPS")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.white)
            }

            Text("\(String(format: "%.0f", memoryMB)) MB")
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(8)
        .background(.ultraThinMaterial.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var fpsColor: Color {
        if fps >= Constants.fpsGreenThreshold {
            return .green
        } else if fps >= Constants.fpsYellowThreshold {
            return .yellow
        } else {
            return .red
        }
    }
}
