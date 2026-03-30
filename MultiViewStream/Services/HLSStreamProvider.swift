import Foundation

struct HLSStreamProvider: StreamProviding {
    func availableStreams() -> [StreamSource] {
        [
            StreamSource(
                title: "Main Stage",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!,
                description: "Primary concert view"
            ),
            StreamSource(
                title: "Backstage Cam",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!,
                description: "Behind the scenes"
            ),
            StreamSource(
                title: "Fan Cam",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/adv_dv_atmos/main.m3u8")!,
                description: "Crowd perspective"
            ),
            StreamSource(
                title: "Interview Room",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
                description: "Artist interviews"
            ),
        ]
    }
}
