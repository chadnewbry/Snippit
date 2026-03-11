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

    // Paper effects
    var edgeStyleRaw: String
    var craftOverlayRaw: String?
    var agingYellowing: Double
    var agingCoffeeStain: Double
    var agingCrumpleTexture: Double
    var agingFadedInk: Double
    var paperCurlEnabled: Bool
    var paperCurlTL: Double
    var paperCurlTR: Double
    var paperCurlBL: Double
    var paperCurlBR: Double
    var fiberDetailIntensity: Double

    var project: CollageProject?

    // MARK: - Computed Properties

    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set { positionX = newValue.x; positionY = newValue.y }
    }

    var scale: CGSize {
        get { CGSize(width: scaleX, height: scaleY) }
        set { scaleX = newValue.width; scaleY = newValue.height }
    }

    var edgeStyle: EdgeStyle {
        get { EdgeStyle(rawValue: edgeStyleRaw) ?? .roughTear }
        set { edgeStyleRaw = newValue.rawValue }
    }

    var craftOverlay: CraftOverlayType? {
        get { craftOverlayRaw.flatMap { CraftOverlayType(rawValue: $0) } }
        set { craftOverlayRaw = newValue?.rawValue }
    }

    var agingEffect: AgingEffect {
        get {
            AgingEffect(
                yellowing: agingYellowing,
                coffeeStain: agingCoffeeStain,
                crumpleTexture: agingCrumpleTexture,
                fadedInk: agingFadedInk
            )
        }
        set {
            agingYellowing = newValue.yellowing
            agingCoffeeStain = newValue.coffeeStain
            agingCrumpleTexture = newValue.crumpleTexture
            agingFadedInk = newValue.fadedInk
        }
    }

    var paperCurl: PaperCurlEffect {
        get {
            PaperCurlEffect(
                enabled: paperCurlEnabled,
                cornerIntensity: [paperCurlTL, paperCurlTR, paperCurlBL, paperCurlBR]
            )
        }
        set {
            paperCurlEnabled = newValue.enabled
            if newValue.cornerIntensity.count >= 4 {
                paperCurlTL = newValue.cornerIntensity[0]
                paperCurlTR = newValue.cornerIntensity[1]
                paperCurlBL = newValue.cornerIntensity[2]
                paperCurlBR = newValue.cornerIntensity[3]
            }
        }
    }

    init(
        imageData: Data,
        position: CGPoint = .zero,
        rotation: Double = 0,
        scale: CGSize = CGSize(width: 1, height: 1),
        zIndex: Int = 0,
        rippedEdgeSeed: Int = Int.random(in: 0...Int.max),
        rippedEdgeRoughness: Double = 0.5,
        edgeStyle: EdgeStyle = .roughTear,
        craftOverlay: CraftOverlayType? = nil,
        agingEffect: AgingEffect = .none,
        paperCurl: PaperCurlEffect = .none,
        fiberDetailIntensity: Double = 0.3
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
        self.edgeStyleRaw = edgeStyle.rawValue
        self.craftOverlayRaw = craftOverlay?.rawValue
        self.agingYellowing = agingEffect.yellowing
        self.agingCoffeeStain = agingEffect.coffeeStain
        self.agingCrumpleTexture = agingEffect.crumpleTexture
        self.agingFadedInk = agingEffect.fadedInk
        self.paperCurlEnabled = paperCurl.enabled
        self.paperCurlTL = paperCurl.cornerIntensity.count > 0 ? paperCurl.cornerIntensity[0] : 0
        self.paperCurlTR = paperCurl.cornerIntensity.count > 1 ? paperCurl.cornerIntensity[1] : 0
        self.paperCurlBL = paperCurl.cornerIntensity.count > 2 ? paperCurl.cornerIntensity[2] : 0
        self.paperCurlBR = paperCurl.cornerIntensity.count > 3 ? paperCurl.cornerIntensity[3] : 0
        self.fiberDetailIntensity = fiberDetailIntensity
    }
}

#if DEBUG
extension ClippedItem: PreviewData {
    static var preview: ClippedItem {
        ClippedItem(
            imageData: Data(),
            position: CGPoint(x: 200, y: 400),
            rotation: -0.15,
            zIndex: 0,
            edgeStyle: .roughTear,
            agingEffect: AgingEffect(yellowing: 0.3, coffeeStain: 0.1)
        )
    }

    static var previewList: [ClippedItem] {
        [
            ClippedItem(imageData: Data(), position: CGPoint(x: 100, y: 200), rotation: 0.1, zIndex: 0, edgeStyle: .roughTear),
            ClippedItem(imageData: Data(), position: CGPoint(x: 300, y: 500), rotation: -0.2, zIndex: 1, edgeStyle: .scissorsCut, craftOverlay: .washiTape),
            ClippedItem(imageData: Data(), position: CGPoint(x: 500, y: 300), rotation: 0.05, zIndex: 2, edgeStyle: .burntEdge, agingEffect: AgingEffect(yellowing: 0.5)),
        ]
    }
}
#endif
