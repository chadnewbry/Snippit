import Foundation

/// Manages fetching magazines and pages from the Internet Archive Magazine Rack.
@Observable
final class MagazineManager {
    private(set) var magazines: [MagazineItem] = []
    private(set) var isLoading = false
    private(set) var error: Error?

    private let session: URLSession
    private let baseURL = URL(string: "https://archive.org")!

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Search magazines by query.
    func search(query: String, page: Int = 1, count: Int = 20) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            var components = URLComponents(url: baseURL.appendingPathComponent("advancedsearch.php"), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "q", value: "collection:magazinerack \(query)"),
                URLQueryItem(name: "fl[]", value: "identifier,title,description,date,imagecount"),
                URLQueryItem(name: "sort[]", value: "downloads desc"),
                URLQueryItem(name: "rows", value: "\(count)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "output", value: "json"),
            ]

            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)

            magazines = response.response.docs.map { doc in
                MagazineItem(
                    identifier: doc.identifier,
                    title: doc.title,
                    description: doc.description,
                    date: doc.date,
                    coverURL: URL(string: "https://archive.org/services/img/\(doc.identifier)"),
                    pageCount: doc.imagecount
                )
            }
        } catch {
            self.error = error
        }
    }

    /// Fetch page image URLs for a specific magazine.
    func fetchPages(for magazine: MagazineItem) async throws -> [MagazinePage] {
        let url = baseURL.appendingPathComponent("metadata/\(magazine.identifier)/files")
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(ArchiveFilesResponse.self, from: data)

        return response.result
            .filter { $0.name.hasSuffix(".jpg") || $0.name.hasSuffix(".jp2") }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            .enumerated()
            .map { index, file in
                MagazinePage(
                    magazineIdentifier: magazine.identifier,
                    pageNumber: index,
                    imageURL: URL(string: "https://archive.org/download/\(magazine.identifier)/\(file.name)")!
                )
            }
    }
}

// MARK: - API Response Types

private struct ArchiveSearchResponse: Codable {
    let response: ArchiveResponseBody
}

private struct ArchiveResponseBody: Codable {
    let docs: [ArchiveDoc]
}

private struct ArchiveDoc: Codable {
    let identifier: String
    let title: String
    let description: String?
    let date: String?
    let imagecount: Int?
}

private struct ArchiveFilesResponse: Codable {
    let result: [ArchiveFile]
}

private struct ArchiveFile: Codable {
    let name: String
}
