import Foundation

enum StreamStatus: Sendable, Equatable {
    case idle
    case loading
    case buffering
    case playing
    case paused
    case error(String)

    var displayText: String {
        switch self {
        case .idle: return "Idle"
        case .loading: return "Loading..."
        case .buffering: return "Buffering..."
        case .playing: return "Live"
        case .paused: return "Paused"
        case .error(let msg): return "Error: \(msg)"
        }
    }

    var isActive: Bool {
        switch self {
        case .playing, .buffering: return true
        default: return false
        }
    }
}
