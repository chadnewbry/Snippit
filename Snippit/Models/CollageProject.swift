import Foundation
import SwiftData
import CoreGraphics

@Model
final class CollageProject {
    var name: String
    var canvasWidth: Double
    var canvasHeight: Double
    var createdAt: Date
    var modifiedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ClippedItem.project)
    var layers: [ClippedItem]

    var canvasSize: CGSize {
        get { CGSize(width: canvasWidth, height: canvasHeight) }
        set { canvasWidth = newValue.width; canvasHeight = newValue.height }
    }

    init(name: String, canvasSize: CGSize = CGSize(width: 1080, height: 1920)) {
        self.name = name
        self.canvasWidth = canvasSize.width
        self.canvasHeight = canvasSize.height
        self.createdAt = .now
        self.modifiedAt = .now
        self.layers = []
    }
}

#if DEBUG
extension CollageProject: PreviewData {
    static var preview: CollageProject {
        let project = CollageProject(name: "Summer Vibes")
        project.layers = ClippedItem.previewList
        return project
    }

    static var previewList: [CollageProject] {
        [
            CollageProject(name: "Summer Vibes"),
            CollageProject(name: "Retro Dreams"),
            CollageProject(name: "Fashion Forward"),
            CollageProject(name: "Travel Inspo"),
        ]
    }
}
#endif
