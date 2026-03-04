import Foundation

struct StarterTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let canvasSize: CanvasSize

    static let all: [StarterTemplate] = [
        StarterTemplate(name: "Mood Board", icon: "heart.fill", description: "Express your aesthetic", canvasSize: .square),
        StarterTemplate(name: "Vision Board", icon: "eye.fill", description: "Manifest your goals", canvasSize: .portrait),
        StarterTemplate(name: "Journal Page", icon: "book.fill", description: "Tell your story", canvasSize: .a4),
        StarterTemplate(name: "Scrapbook", icon: "photo.on.rectangle.angled", description: "Preserve memories", canvasSize: .landscape),
    ]
}

#if DEBUG
extension StarterTemplate: PreviewData {
    static var preview: StarterTemplate { StarterTemplate.all[0] }
    static var previewList: [StarterTemplate] { StarterTemplate.all }
}
#endif
