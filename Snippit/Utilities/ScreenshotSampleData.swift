#if DEBUG
import Foundation
import SwiftData
import SwiftUI

/// Populates the database with curated sample data for App Store screenshot capture.
enum ScreenshotSampleData {
    /// Whether the app was launched with the `--screenshot-mode` argument.
    static let isScreenshotMode = ProcessInfo.processInfo.arguments.contains("--screenshot-mode")

    /// Clears existing data and inserts polished sample content for screenshots.
    @MainActor
    static func populate(context: ModelContext) {
        // Clear existing data
        try? context.delete(model: TextElement.self)
        try? context.delete(model: ClippedItem.self)
        try? context.delete(model: CollageProject.self)

        // Create sample collage projects with realistic names
        let projects: [(String, CGSize, TimeInterval)] = [
            ("Summer in Positano", CGSize(width: 1080, height: 1920), -86400 * 2),
            ("Vintage Fashion Mood Board", CGSize(width: 1080, height: 1080), -86400 * 5),
            ("Travel Journal — Tokyo", CGSize(width: 1080, height: 1920), -86400 * 10),
            ("Recipe Clippings", CGSize(width: 1080, height: 1350), -86400 * 14),
            ("Wedding Inspiration", CGSize(width: 1080, height: 1920), -86400 * 21),
            ("90s Nostalgia Board", CGSize(width: 1080, height: 1080), -86400 * 30),
        ]

        for (name, size, offset) in projects {
            let project = CollageProject(name: name, canvasSize: size)
            project.createdAt = Date(timeIntervalSinceNow: offset)
            project.modifiedAt = Date(timeIntervalSinceNow: offset + 3600)

            // Add sample clipped items to each project
            let clippings = createSampleClippings()
            for clipping in clippings {
                clipping.project = project
            }
            project.layers = clippings

            // Add sample text elements to each project
            let texts = createSampleTextElements(projectName: name)
            for text in texts {
                text.project = project
            }
            project.textElements = texts

            context.insert(project)
        }

        try? context.save()
    }

    // MARK: - Private Helpers

    private static func createSampleClippings() -> [ClippedItem] {
        let placeholderData = createPlaceholderImageData()

        return [
            ClippedItem(
                imageData: placeholderData,
                position: CGPoint(x: 200, y: 350),
                rotation: -0.08,
                scale: CGSize(width: 1.2, height: 1.2),
                zIndex: 0,
                edgeStyle: .roughTear,
                agingEffect: AgingEffect(yellowing: 0.2, coffeeStain: 0.05)
            ),
            ClippedItem(
                imageData: placeholderData,
                position: CGPoint(x: 450, y: 600),
                rotation: 0.12,
                scale: CGSize(width: 0.9, height: 0.9),
                zIndex: 1,
                edgeStyle: .scissorsCut,
                craftOverlay: .washiTape
            ),
            ClippedItem(
                imageData: placeholderData,
                position: CGPoint(x: 300, y: 900),
                rotation: -0.05,
                zIndex: 2,
                edgeStyle: .roughTear,
                agingEffect: AgingEffect(yellowing: 0.4, crumpleTexture: 0.2)
            ),
        ]
    }

    private static func createSampleTextElements(projectName: String) -> [TextElement] {
        return [
            TextElement(
                text: "✨ Dream Big ✨",
                fontName: "Snell Roundhand",
                fontSize: 28,
                position: CGPoint(x: 300, y: 200),
                rotation: 0,
                scale: CGSize(width: 1, height: 1),
                zIndex: 10,
                colorHex: "#D4A574"
            ),
            TextElement(
                text: projectName,
                fontName: "Georgia",
                fontSize: 22,
                position: CGPoint(x: 300, y: 1400),
                rotation: 0,
                scale: CGSize(width: 1, height: 1),
                zIndex: 11,
                colorHex: "#2C3E50"
            ),
        ]
    }

    private static func createPlaceholderImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let image = renderer.image { ctx in
            let colors: [UIColor] = [.systemTeal, .systemPink, .systemOrange, .systemPurple]
            let color = colors.randomElement() ?? .systemTeal
            color.withAlphaComponent(0.6).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        return image.pngData() ?? Data()
    }
}
#endif
