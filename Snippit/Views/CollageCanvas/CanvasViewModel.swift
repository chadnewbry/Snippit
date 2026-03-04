import CoreGraphics
import Observation
import SwiftData
import SwiftUI
import UIKit

// MARK: - Canvas Background

enum CanvasBackgroundStyle: String, CaseIterable, Identifiable {
    case white = "White"
    case cream = "Cream"
    case black = "Black"
    case kraft = "Kraft"
    case cork = "Cork"
    case parchment = "Parchment"
    case gradientSunset = "Sunset"
    case gradientOcean = "Ocean"
    case gradientForest = "Forest"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .white, .cream, .black: return "circle.fill"
        case .kraft, .cork, .parchment: return "doc.fill"
        case .gradientSunset, .gradientOcean, .gradientForest: return "circle.lefthalf.filled"
        }
    }

    var primaryColor: Color {
        switch self {
        case .white: return .white
        case .cream: return Color(red: 0.98, green: 0.96, blue: 0.90)
        case .black: return .black
        case .kraft: return Color(red: 0.76, green: 0.64, blue: 0.48)
        case .cork: return Color(red: 0.82, green: 0.71, blue: 0.55)
        case .parchment: return Color(red: 0.95, green: 0.91, blue: 0.82)
        case .gradientSunset: return Color(red: 1.0, green: 0.55, blue: 0.35)
        case .gradientOcean: return Color(red: 0.25, green: 0.55, blue: 0.85)
        case .gradientForest: return Color(red: 0.20, green: 0.55, blue: 0.35)
        }
    }

    var secondaryColor: Color? {
        switch self {
        case .gradientSunset: return Color(red: 0.85, green: 0.25, blue: 0.55)
        case .gradientOcean: return Color(red: 0.45, green: 0.85, blue: 0.80)
        case .gradientForest: return Color(red: 0.65, green: 0.82, blue: 0.35)
        default: return nil
        }
    }

    var hasTexture: Bool {
        switch self {
        case .kraft, .cork, .parchment: return true
        default: return false
        }
    }
}

// MARK: - Undo Action

enum CanvasAction {
    case addItem(ClippedItem)
    case removeItem(ClippedItem, index: Int)
    case moveItem(ClippedItem, from: CGPoint, to: CGPoint)
    case scaleItem(ClippedItem, from: CGSize, to: CGSize)
    case rotateItem(ClippedItem, from: Double, to: Double)
    case flipItem(ClippedItem, axis: FlipAxis, from: CGSize, to: CGSize)
    case reorderItem(ClippedItem, fromZ: Int, toZ: Int)
}

enum FlipAxis { case horizontal, vertical }

// MARK: - ViewModel

@Observable
final class CanvasViewModel {
    var canvasOffset: CGSize = .zero
    var canvasScale: CGFloat = 1.0
    var selectedItem: ClippedItem?
    var background: CanvasBackgroundStyle = .white
    var showGrid = false

    // Snap guides
    var horizontalGuide: CGFloat?
    var verticalGuide: CGFloat?

    // Undo/redo
    private(set) var undoStack: [CanvasAction] = []
    private(set) var redoStack: [CanvasAction] = []

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    // MARK: - Layer Management

    func sortedLayers(of project: CollageProject) -> [ClippedItem] {
        project.layers.sorted { $0.zIndex < $1.zIndex }
    }

    func addItem(_ item: ClippedItem, to project: CollageProject) {
        item.zIndex = (project.layers.map(\.zIndex).max() ?? -1) + 1
        project.layers.append(item)
        project.modifiedAt = .now
        pushUndo(.addItem(item))
    }

    func removeItem(_ item: ClippedItem, from project: CollageProject) {
        guard let idx = project.layers.firstIndex(where: { $0.id == item.id }) else { return }
        project.layers.remove(at: idx)
        project.modifiedAt = .now
        pushUndo(.removeItem(item, index: idx))
        if selectedItem?.id == item.id { selectedItem = nil }
    }

    func bringForward(_ item: ClippedItem, in project: CollageProject) {
        let sorted = sortedLayers(of: project)
        guard let idx = sorted.firstIndex(where: { $0.id == item.id }),
              idx < sorted.count - 1 else { return }
        let above = sorted[idx + 1]
        let oldZ = item.zIndex
        item.zIndex = above.zIndex
        above.zIndex = oldZ
        project.modifiedAt = .now
        pushUndo(.reorderItem(item, fromZ: oldZ, toZ: item.zIndex))
    }

    func sendBackward(_ item: ClippedItem, in project: CollageProject) {
        let sorted = sortedLayers(of: project)
        guard let idx = sorted.firstIndex(where: { $0.id == item.id }),
              idx > 0 else { return }
        let below = sorted[idx - 1]
        let oldZ = item.zIndex
        item.zIndex = below.zIndex
        below.zIndex = oldZ
        project.modifiedAt = .now
        pushUndo(.reorderItem(item, fromZ: oldZ, toZ: item.zIndex))
    }

    // MARK: - Transforms

    func moveItem(_ item: ClippedItem, to newPosition: CGPoint, from oldPosition: CGPoint) {
        item.position = newPosition
        pushUndo(.moveItem(item, from: oldPosition, to: newPosition))
    }

    func scaleItem(_ item: ClippedItem, to newScale: CGSize, from oldScale: CGSize) {
        item.scale = newScale
        pushUndo(.scaleItem(item, from: oldScale, to: newScale))
    }

    func rotateItem(_ item: ClippedItem, to newRotation: Double, from oldRotation: Double) {
        item.rotation = newRotation
        pushUndo(.rotateItem(item, from: oldRotation, to: newRotation))
    }

    func flipHorizontal(_ item: ClippedItem) {
        let old = item.scale
        let new = CGSize(width: -old.width, height: old.height)
        item.scale = new
        pushUndo(.flipItem(item, axis: .horizontal, from: old, to: new))
    }

    func flipVertical(_ item: ClippedItem) {
        let old = item.scale
        let new = CGSize(width: old.width, height: -old.height)
        item.scale = new
        pushUndo(.flipItem(item, axis: .vertical, from: old, to: new))
    }

    // MARK: - Snap Guides

    func updateSnapGuides(for item: ClippedItem, in project: CollageProject) {
        let threshold: CGFloat = 8
        let center = CGPoint(x: item.positionX, y: item.positionY)
        let canvasCenter = CGPoint(x: project.canvasWidth / 2, y: project.canvasHeight / 2)

        horizontalGuide = abs(center.y - canvasCenter.y) < threshold ? canvasCenter.y : nil
        verticalGuide = abs(center.x - canvasCenter.x) < threshold ? canvasCenter.x : nil

        if horizontalGuide == nil || verticalGuide == nil {
            for other in project.layers where other.id != item.id {
                if horizontalGuide == nil && abs(center.y - other.positionY) < threshold {
                    horizontalGuide = other.positionY
                }
                if verticalGuide == nil && abs(center.x - other.positionX) < threshold {
                    verticalGuide = other.positionX
                }
            }
        }
    }

    func clearSnapGuides() {
        horizontalGuide = nil
        verticalGuide = nil
    }

    func snapPosition(_ position: CGPoint, in project: CollageProject) -> CGPoint {
        let threshold: CGFloat = 8
        var snapped = position
        let canvasCenter = CGPoint(x: project.canvasWidth / 2, y: project.canvasHeight / 2)

        if abs(position.x - canvasCenter.x) < threshold { snapped.x = canvasCenter.x }
        if abs(position.y - canvasCenter.y) < threshold { snapped.y = canvasCenter.y }

        for item in project.layers {
            if abs(position.x - item.positionX) < threshold { snapped.x = item.positionX }
            if abs(position.y - item.positionY) < threshold { snapped.y = item.positionY }
        }

        return snapped
    }

    // MARK: - Undo / Redo

    func undo() {
        guard let action = undoStack.popLast() else { return }
        applyInverse(of: action)
        redoStack.append(action)
    }

    func redo() {
        guard let action = redoStack.popLast() else { return }
        applyForward(action)
        undoStack.append(action)
    }

    private func pushUndo(_ action: CanvasAction) {
        undoStack.append(action)
        redoStack.removeAll()
    }

    private func applyInverse(of action: CanvasAction) {
        switch action {
        case .addItem(let item):
            item.project?.layers.removeAll { $0.id == item.id }
        case .removeItem(let item, _):
            item.project?.layers.append(item)
        case .moveItem(let item, let from, _):
            item.position = from
        case .scaleItem(let item, let from, _):
            item.scale = from
        case .rotateItem(let item, let from, _):
            item.rotation = from
        case .flipItem(let item, _, let from, _):
            item.scale = from
        case .reorderItem(let item, let fromZ, _):
            item.zIndex = fromZ
        }
    }

    private func applyForward(_ action: CanvasAction) {
        switch action {
        case .addItem(let item):
            item.project?.layers.append(item)
        case .removeItem(let item, _):
            item.project?.layers.removeAll { $0.id == item.id }
        case .moveItem(let item, _, let to):
            item.position = to
        case .scaleItem(let item, _, let to):
            item.scale = to
        case .rotateItem(let item, _, let to):
            item.rotation = to
        case .flipItem(let item, _, _, let to):
            item.scale = to
        case .reorderItem(let item, _, let toZ):
            item.zIndex = toZ
        }
    }
}
