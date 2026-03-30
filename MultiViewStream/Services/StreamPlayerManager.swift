import AVFoundation
import Combine

@MainActor
@Observable
final class StreamPlayerManager {
    private(set) var players: [UUID: AVPlayer] = [:]
    private(set) var statuses: [UUID: StreamStatus] = [:]
    private var observations: [UUID: [NSKeyValueObservation]] = [:]
    private var sources: [StreamSource] = []
    private(set) var primaryStreamID: UUID?

    var activeStreams: [StreamSource] { sources }

    func loadStreams(from provider: StreamProviding) {
        let streams = provider.availableStreams()
        sources = Array(streams.prefix(Constants.maxConcurrentStreams))
        primaryStreamID = sources.first?.id

        for source in sources {
            statuses[source.id] = .idle
        }
    }

    func startStream(_ source: StreamSource, configuration: StreamConfiguration = .thumbnail) {
        guard players[source.id] == nil else { return }

        let playerItem = AVPlayerItem(url: source.url)
        playerItem.preferredPeakBitRate = configuration.preferredPeakBitRate
        playerItem.preferredForwardBufferDuration = configuration.preferredForwardBufferDuration
        playerItem.preferredMaximumResolution = configuration.preferredMaximumResolution

        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = true
        players[source.id] = player
        statuses[source.id] = .loading

        observePlayer(player, for: source.id)
        player.play()
    }

    func stopStream(_ id: UUID) {
        players[id]?.pause()
        players[id]?.replaceCurrentItem(with: nil)
        players.removeValue(forKey: id)
        observations.removeValue(forKey: id)
        statuses[id] = .idle
    }

    func stopAll() {
        for id in Array(players.keys) {
            stopStream(id)
        }
        sources.removeAll()
    }

    func player(for id: UUID) -> AVPlayer? {
        players[id]
    }

    func promoteToPrimary(_ id: UUID, in layout: StreamLayout) {
        guard sources.contains(where: { $0.id == id }) else { return }
        primaryStreamID = id

        // Adjust bitrates: primary gets high, others get thumbnail
        for source in sources {
            guard let player = players[source.id],
                  let item = player.currentItem else { continue }

            if source.id == id {
                item.preferredPeakBitRate = StreamConfiguration.primary.preferredPeakBitRate
                item.preferredForwardBufferDuration = StreamConfiguration.primary.preferredForwardBufferDuration
                item.preferredMaximumResolution = StreamConfiguration.primary.preferredMaximumResolution
            } else {
                item.preferredPeakBitRate = StreamConfiguration.thumbnail.preferredPeakBitRate
                item.preferredForwardBufferDuration = StreamConfiguration.thumbnail.preferredForwardBufferDuration
                item.preferredMaximumResolution = StreamConfiguration.thumbnail.preferredMaximumResolution
            }
        }
    }

    func startAllStreams() {
        for (index, source) in sources.enumerated() {
            let isPrimary = source.id == primaryStreamID
            let config: StreamConfiguration = isPrimary ? .primary : .thumbnail
            if players[source.id] == nil {
                startStream(source, configuration: config)
            }
            // Unmute primary only
            players[source.id]?.isMuted = !isPrimary
        }
    }

    func unmuteOnly(_ id: UUID) {
        for (streamID, player) in players {
            player.isMuted = streamID != id
        }
    }

    // MARK: - Memory management

    func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return result == KERN_SUCCESS ? info.resident_size : 0
    }

    func enforceMemoryLimit() {
        let usage = currentMemoryUsage()
        guard usage > Constants.memoryWarningThreshold else { return }

        // Pause the lowest-priority (last non-primary) stream
        if let lastNonPrimary = sources.last(where: { $0.id != primaryStreamID }) {
            players[lastNonPrimary.id]?.pause()
            statuses[lastNonPrimary.id] = .paused
        }
    }

    // MARK: - KVO Observation

    private func observePlayer(_ player: AVPlayer, for id: UUID) {
        nonisolated(unsafe) let weakSelf = self
        var obs: [NSKeyValueObservation] = []

        if let item = player.currentItem {
            let statusObs = item.observe(\.status, options: [.new]) { item, _ in
                Task { @MainActor in
                    switch item.status {
                    case .readyToPlay:
                        weakSelf.statuses[id] = .playing
                    case .failed:
                        weakSelf.statuses[id] = .error(item.error?.localizedDescription ?? "Unknown error")
                    default:
                        break
                    }
                }
            }
            obs.append(statusObs)

            let bufferObs = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { item, _ in
                Task { @MainActor in
                    if item.isPlaybackBufferEmpty {
                        weakSelf.statuses[id] = .buffering
                    }
                }
            }
            obs.append(bufferObs)

            let likelyObs = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { item, _ in
                Task { @MainActor in
                    if item.isPlaybackLikelyToKeepUp {
                        weakSelf.statuses[id] = .playing
                    }
                }
            }
            obs.append(likelyObs)
        }

        let rateObs = player.observe(\.rate, options: [.new]) { player, _ in
            Task { @MainActor in
                if player.rate == 0, weakSelf.statuses[id] == .playing {
                    weakSelf.statuses[id] = .paused
                }
            }
        }
        obs.append(rateObs)

        observations[id] = obs
    }
}
