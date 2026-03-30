import Foundation

protocol StreamProviding: Sendable {
    func availableStreams() -> [StreamSource]
}
