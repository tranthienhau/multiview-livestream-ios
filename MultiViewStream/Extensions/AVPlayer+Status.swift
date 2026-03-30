import AVFoundation
import Combine

extension AVPlayer {
    var isPlaying: Bool {
        rate != 0 && error == nil
    }
}

extension AVPlayerItem {
    var isBuffering: Bool {
        isPlaybackBufferEmpty && !isPlaybackLikelyToKeepUp
    }
}
