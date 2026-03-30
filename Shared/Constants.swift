import Foundation

enum Constants {
    static let maxConcurrentStreams = 4
    static let thumbnailBitrate: Double = 500_000      // 500 kbps
    static let primaryBitrate: Double = 2_000_000      // 2 Mbps
    static let thumbnailBufferDuration: Double = 2.0   // 2 seconds
    static let memoryWarningThreshold: UInt64 = 400 * 1024 * 1024  // 400 MB
    static let fpsGreenThreshold: Double = 55.0
    static let fpsYellowThreshold: Double = 30.0
}
