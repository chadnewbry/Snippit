import Foundation

/// Represents a magazine from the Internet Archive Magazine Rack.
struct MagazineItem: Identifiable, Codable, Sendable {
    let identifier: String
    let title: String
    let description: String?
    let date: String?
    let coverURL: URL?
    let pageCount: Int?

    var id: String { identifier }
}

/// A single page image from a magazine.
struct MagazinePage: Identifiable, Sendable {
    let magazineIdentifier: String
    let pageNumber: Int
    let imageURL: URL

    var id: String { "\(magazineIdentifier)-\(pageNumber)" }
}
