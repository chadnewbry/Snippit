import Foundation

/// Manages fetching magazines and pages from the Internet Archive Magazine Rack.
@Observable
final class MagazineManager {
    private(set) var magazines: [MagazineItem] = []
    private(set) var searchSuggestions: [String] = []
    private(set) var isLoading = false
    private(set) var error: Error?
    private(set) var currentPage = 1
    private(set) var hasMore = true

    private let session: URLSession
    private let baseURL = URL(string: "https://archive.org")!
    private var currentTask: Task<Void, Never>?

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Search magazines with optional category and decade filters.
    func search(
        query: String = "",
        category: MagazineCategory = .all,
        decade: MagazineDecade = .any,
        page: Int = 1,
        count: Int = 40,
        append: Bool = false
    ) async {
        isLoading = true
        error = nil
        if !append { currentPage = page }
        defer { isLoading = false }

        do {
            let searchQuery = buildQuery(text: query, category: category, decade: decade)
            var components = URLComponents(url: baseURL.appendingPathComponent("advancedsearch.php"), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "q", value: searchQuery),
                URLQueryItem(name: "fl[]", value: "identifier,title,description,date,imagecount"),
                URLQueryItem(name: "sort[]", value: "downloads desc"),
                URLQueryItem(name: "rows", value: "\(count)"),
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "output", value: "json"),
            ]

            let (data, _) = try await session.data(from: components.url!)
            let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)

            let newItems = response.response.docs.map { doc in
                MagazineItem(
                    identifier: doc.identifier,
                    title: doc.title,
                    description: doc.description,
                    date: doc.date,
                    coverURL: URL(string: "https://archive.org/services/img/\(doc.identifier)"),
                    pageCount: doc.imagecount
                )
            }

            if append {
                magazines.append(contentsOf: newItems)
            } else {
                magazines = newItems
            }
            hasMore = newItems.count == count
            currentPage = page
        } catch {
            self.error = error
        }
    }

    /// Load next page of results.
    func loadMore(query: String, category: MagazineCategory, decade: MagazineDecade) async {
        guard !isLoading, hasMore else { return }
        await search(query: query, category: category, decade: decade, page: currentPage + 1, append: true)
    }

    /// Fetch typeahead suggestions from the Internet Archive.
    func fetchSuggestions(for query: String) async {
        guard query.count >= 2 else {
            searchSuggestions = []
            return
        }

        currentTask?.cancel()
        currentTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            do {
                var components = URLComponents(url: baseURL.appendingPathComponent("advancedsearch.php"), resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "q", value: "collection:magazinerack title:(\(query))"),
                    URLQueryItem(name: "fl[]", value: "title"),
                    URLQueryItem(name: "rows", value: "8"),
                    URLQueryItem(name: "output", value: "json"),
                ]

                let (data, _) = try await session.data(from: components.url!)
                let response = try JSONDecoder().decode(ArchiveSearchResponse.self, from: data)

                guard !Task.isCancelled else { return }
                searchSuggestions = Array(Set(response.response.docs.map(\.title))).sorted().prefix(6).map { $0 }
            } catch {
                if !Task.isCancelled {
                    searchSuggestions = []
                }
            }
        }
    }

    /// Search a curated collection.
    func searchCollection(_ collection: CuratedCollection, count: Int = 40) async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            var components = URLComponents(url: baseURL.appendingPathComponent("advancedsearch.php"), resolvingAgainstBaseURL: false)!
            components.queryItems = [
                URLQueryItem(name: "q", value: collection.searchQuery),
                URLQueryItem(name: "fl[]", value: "identifier,title,description,date,imagecount"),
                URLQueryItem(name: "sort[]", value: "downloads desc"),
                URLQueryItem(name: "rows", value: "\(count)"),
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

    // MARK: - Private

    private func buildQuery(text: String, category: MagazineCategory, decade: MagazineDecade) -> String {
        var parts = ["collection:magazinerack"]
        if !text.isEmpty {
            parts.append("(\(text))")
        }
        if !category.searchQuery.isEmpty {
            parts.append(category.searchQuery)
        }
        if let range = decade.dateRange {
            parts.append("date:[\(range.start) TO \(range.end)]")
        }
        return parts.joined(separator: " AND ")
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
