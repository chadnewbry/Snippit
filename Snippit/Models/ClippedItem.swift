import Foundation
import SwiftData
import CoreGraphics

@Model
final class ClippedItem {
    var imageData: Data
    var positionX: Double
    var positionY: Double
    var rotation: Double
    var scaleX: Double
    var scaleY: Double
    var zIndex: Int
    var rippedEdgeSeed: Int
    var rippedEdgeRoughness: Double
    var createdAt: Date

    var project: CollageProject?

    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }

    var scale: CGSize {
        get { CGSize(width: scaleX, height: scaleY) }
        set { scaleX = newValue.width; scaleY = newValue.height }
    }

    init(
        imageData: Data,
        position: CGPoint = .zero,
        rotation: Double = 0,
        scale: CGSize = CGSize(width: 1, height: 1),
        zIndex: Int = 0,
        rippedEdgeSeed: Int = Int.random(in: 0...Int.max),
        rippedEdgeRoughness: Double = 0.5
    ) {
        self.imageData = imageData
        self.positionX = position.x
        self.positionY = position.y
        self.rotation = rotation
        self.scaleX = scale.width
        self.scaleY = scale.height
        self.zIndex = zIndex
        self.rippedEdgeSeed = rippedEdgeSeed
        self.rippedEdgeRoughness = rippedEdgeRoughness
        self.createdAt = .now
    }
}

#if DEBUG
extension ClippedItem: PreviewData {
    static var preview: ClippedItem {
        ClippedItem(
            imageData: Data(),
            position: CGPoint(x: 200, y: 400),
            rotation: -0.15,
            zIndex: 0
        )
    }

    static var previewList: [ClippedItem] {
        [
            ClippedItem(imageData: Data(), position: CGPoint(x: 100, y: 200), rotation: 0.1, zIndex: 0),
            ClippedItem(imageData: Data(), position: CGPoint(x: 300, y: 500), rotation: -0.2, zIndex: 1),
            ClippedItem(imageData: Data(), position: CGPoint(x: 500, y: 300), rotation: 0.05, zIndex: 2),
        ]
    }
}
#endif
