import UIKit
import CoreMedia

struct StreamConfiguration: Sendable {
    let preferredPeakBitRate: Double
    let preferredForwardBufferDuration: TimeInterval
    let preferredMaximumResolution: CGSize

    static let primary = StreamConfiguration(
        preferredPeakBitRate: Constants.primaryBitrate,
        preferredForwardBufferDuration: 0, // system default
        preferredMaximumResolution: CGSize(width: 1920, height: 1080)
    )

    static let thumbnail = StreamConfiguration(
        preferredPeakBitRate: Constants.thumbnailBitrate,
        preferredForwardBufferDuration: Constants.thumbnailBufferDuration,
        preferredMaximumResolution: CGSize(width: 640, height: 360)
    )

    static func forTileSize(_ size: CGSize, isPrimary: Bool) -> StreamConfiguration {
        if isPrimary {
            return .primary
        }
        let scale = UIScreen.main.scale
        return StreamConfiguration(
            preferredPeakBitRate: Constants.thumbnailBitrate,
            preferredForwardBufferDuration: Constants.thumbnailBufferDuration,
            preferredMaximumResolution: CGSize(width: size.width * scale, height: size.height * scale)
        )
    }
}
