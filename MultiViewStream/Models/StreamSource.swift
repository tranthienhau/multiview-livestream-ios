import Foundation

struct StreamSource: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let url: URL
    let description: String

    init(id: UUID = UUID(), title: String, url: URL, description: String = "") {
        self.id = id
        self.title = title
        self.url = url
        self.description = description
    }
}
