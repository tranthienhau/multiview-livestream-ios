# Multi-View Live Stream Viewer

A native iOS POC demonstrating multi-stream live video playback, inspired by platforms like Klic.gg. Built with SwiftUI + AVFoundation.

## Features

- **Multi-stream playback** - 4 simultaneous HLS streams in a 2x2 grid
- **Dynamic layouts** - Grid (2x2), Primary + Thumbnails, Side-by-Side
- **Smooth transitions** - Spring animations with matchedGeometryEffect
- **Tap-to-promote** - Tap any tile to make it the primary stream
- **Fullscreen mode** - Tap primary stream for immersive viewing
- **Adaptive bitrate** - 2 Mbps for primary, 500 kbps for thumbnails
- **Performance monitoring** - Real-time FPS (CADisplayLink) and memory overlay
- **Memory management** - Auto-pause streams when memory exceeds 400 MB

## Architecture

```
MVVM + Protocol-Oriented Services

App/
  MultiViewStreamApp       @main entry point
  AppState                 @Observable state container

Models/
  StreamSource             Stream metadata (URL, title)
  StreamLayout             Layout enum with geometry calculations
  StreamStatus             Player status (loading, playing, error)

Services/
  StreamProviding          Protocol for stream source abstraction
  HLSStreamProvider        Apple HLS test stream URLs
  StreamPlayerManager      Core: manages multiple AVPlayer instances
  PerformanceMonitor       CADisplayLink FPS + mach task_info memory
  StreamConfiguration      Bitrate/buffer tuning per stream role

Views/
  Home/HomeView            Main screen with grid + controls
  Grid/MultiStreamGridView GeometryReader-based multi-layout grid
  Components/
    VideoPlayerView        UIViewRepresentable wrapping AVPlayerLayer
    StreamTileView         Video tile with overlay (title, status)
    PerformanceOverlayView Color-coded FPS + memory display
  Fullscreen/
    FullscreenPlayerView   Immersive single-stream viewer
```

## Requirements

- iOS 17+
- Xcode 15+
- Swift 6.0
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Build & Run

```bash
# Install XcodeGen (if needed)
brew install xcodegen

# Generate Xcode project
cd poc_next/multiview-livestream
xcodegen generate

# Open in Xcode
open MultiViewStream.xcodeproj

# Or build from command line
xcodebuild -project MultiViewStream.xcodeproj \
  -scheme MultiViewStream \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  build
```

## Test Streams

Uses free public Apple HLS test streams:

| Stream | Format |
|--------|--------|
| bipbop fMP4 | Advanced fMP4 |
| bipbop HEVC | H.265/HEVC |
| Dolby Vision | Dolby Vision + Atmos |
| bipbop Basic | Basic 16:9 H.264 |

## Performance Optimizations

- **Bitrate throttling**: Thumbnail tiles limited to 500 kbps, primary at 2 Mbps
- **Buffer control**: 2s forward buffer for thumbnails, system default for primary
- **Resolution capping**: `preferredMaximumResolution` matched to actual tile pixel size
- **Lazy init**: AVPlayer created on view appear, released on disappear
- **Memory guard**: Auto-pause lowest-priority stream if memory exceeds 400 MB

## Run Tests

```bash
xcodebuild test -project MultiViewStream.xcodeproj \
  -scheme MultiViewStream \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```
