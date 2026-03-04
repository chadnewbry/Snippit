import Foundation
import SwiftData
import CoreGraphics
import SwiftUI

/// A text element that can be placed on the collage canvas.
@Model
final class TextElement {
    var text: String
    var fontName: String
    var fontSize: Double
    var positionX: Double
    var positionY: Double
    var rotation: Double
    var scaleX: Double
    var scaleY: Double
    var zIndex: Int
    var createdAt: Date

    // Styling
    var colorHex: String
    var opacity: Double
    var letterSpacing: Double
    var outlineColorHex: String?
    var outlineWidth: Double
    var shadowRadius: Double
    var shadowOffsetX: Double
    var shadowOffsetY: Double
    var shadowColorHex: String?

    // Modes
    var isRansomNote: Bool
    var isTextOnPaper: Bool
    var paperSeed: Int
    var paperRoughness: Double

    var project: CollageProject?

    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }

    var scale: CGSize {
        get { CGSize(width: scaleX, height: scaleY) }
        set { scaleX = newValue.width; scaleY = newValue.height }
    }

    var color: Color {
        Color(hex: colorHex) ?? .white
    }

    init(
        text: String = "Hello",
        fontName: String = "Helvetica",
        fontSize: Double = 32,
        position: CGPoint = .zero,
        rotation: Double = 0,
        scale: CGSize = CGSize(width: 1, height: 1),
        zIndex: Int = 0,
        colorHex: String = "#FFFFFF",
        opacity: Double = 1.0,
        letterSpacing: Double = 0,
        outlineColorHex: String? = nil,
        outlineWidth: Double = 0,
        shadowRadius: Double = 0,
        shadowOffsetX: Double = 0,
        shadowOffsetY: Double = 0,
        shadowColorHex: String? = nil,
        isRansomNote: Bool = false,
        isTextOnPaper: Bool = false,
        paperSeed: Int = Int.random(in: 0...Int.max),
        paperRoughness: Double = 0.5
    ) {
        self.text = text
        self.fontName = fontName
        self.fontSize = fontSize
        self.positionX = position.x
        self.positionY = position.y
        self.rotation = rotation
        self.scaleX = scale.width
        self.scaleY = scale.height
        self.zIndex = zIndex
        self.createdAt = .now
        self.colorHex = colorHex
        self.opacity = opacity
        self.letterSpacing = letterSpacing
        self.outlineColorHex = outlineColorHex
        self.outlineWidth = outlineWidth
        self.shadowRadius = shadowRadius
        self.shadowOffsetX = shadowOffsetX
        self.shadowOffsetY = shadowOffsetY
        self.shadowColorHex = shadowColorHex
        self.isRansomNote = isRansomNote
        self.isTextOnPaper = isTextOnPaper
        self.paperSeed = paperSeed
        self.paperRoughness = paperRoughness
    }
}

#if DEBUG
extension TextElement: PreviewData {
    static var preview: TextElement {
        TextElement(
            text: "Snippit!",
            fontName: "Georgia",
            fontSize: 48,
            position: CGPoint(x: 200, y: 300),
            rotation: -0.1,
            colorHex: "#FF6B6B"
        )
    }

    static var previewList: [TextElement] {
        [
            TextElement(text: "Hello World", fontName: "Courier", fontSize: 36, position: CGPoint(x: 100, y: 150), colorHex: "#FFFFFF"),
            TextElement(text: "RANSOM", fontName: "Helvetica-Bold", fontSize: 42, position: CGPoint(x: 300, y: 400), isRansomNote: true),
            TextElement(text: "Paper Note", fontName: "AmericanTypewriter", fontSize: 28, position: CGPoint(x: 200, y: 600), isTextOnPaper: true),
            TextElement(text: "Vintage", fontName: "Baskerville", fontSize: 52, position: CGPoint(x: 150, y: 250), colorHex: "#D4A574"),
        ]
    }
}
#endif
