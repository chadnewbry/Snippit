import SwiftUI
import UIKit

struct CanvasItemView: View {
    let item: ClippedItem
    let isSelected: Bool
    let canvasScale: CGFloat
    let onSelect: () -> Void
    let onDragEnd: (CGPoint, CGPoint) -> Void
    let onScaleEnd: (CGSize, CGSize) -> Void
    let onRotateEnd: (Double, Double) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var initialPosition: CGPoint = .zero
    @State private var isDragging = false

    // Resize
    @State private var resizeStartScale: CGSize = .init(width: 1, height: 1)
    @State private var activeCorner: ResizeCorner?

    // Rotation
    @State private var rotationStartAngle: Double = 0
    @State private var currentRotationDelta: Angle = .zero

    private var itemImage: UIImage? {
        UIImage(data: item.imageData)
    }

    private var displayImage: UIImage? {
        PaperEffectsRenderer.applyRippedEdges(
            to: item.imageData,
            seed: item.rippedEdgeSeed,
            roughness: item.rippedEdgeRoughness
        )
    }

    var body: some View {
        let imageSize = itemImage?.size ?? CGSize(width: 150, height: 150)
        let displayWidth = imageSize.width * abs(item.scaleX)
        let displayHeight = imageSize.height * abs(item.scaleY)

        ZStack {
            // Image with ripped edges & shadow
            Group {
                if let img = displayImage {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: displayWidth, height: displayHeight)
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.purple.opacity(0.15))
                        .frame(width: max(displayWidth, 80), height: max(displayHeight, 80))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .scaleEffect(x: item.scaleX < 0 ? -1 : 1, y: item.scaleY < 0 ? -1 : 1)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 2, y: 3)

            // Selection border + handles
            if isSelected {
                Rectangle()
                    .strokeBorder(Color.accentColor, lineWidth: 1.5 / canvasScale)
                    .frame(width: displayWidth + 4, height: displayHeight + 4)

                // Corner resize handles
                ForEach(ResizeCorner.allCases, id: \.self) { corner in
                    ResizeHandle(corner: corner, canvasScale: canvasScale)
                        .position(corner.position(in: CGSize(width: displayWidth + 4, height: displayHeight + 4)))
                        .gesture(resizeGesture(corner: corner, imageSize: imageSize))
                }

                // Rotation handle
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 14 / canvasScale, height: 14 / canvasScale)
                    .offset(y: -(displayHeight / 2 + 28))
                    .gesture(rotationGesture)
            }
        }
        .rotationEffect(.radians(item.rotation) + currentRotationDelta)
        .position(
            x: item.positionX + (isDragging ? dragOffset.width : 0),
            y: item.positionY + (isDragging ? dragOffset.height : 0)
        )
        .onTapGesture { onSelect() }
        .gesture(dragGesture)
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    initialPosition = item.position
                    onSelect()
                }
                dragOffset = CGSize(
                    width: value.translation.width / canvasScale,
                    height: value.translation.height / canvasScale
                )
            }
            .onEnded { _ in
                let newPos = CGPoint(
                    x: initialPosition.x + dragOffset.width,
                    y: initialPosition.y + dragOffset.height
                )
                isDragging = false
                dragOffset = .zero
                onDragEnd(initialPosition, newPos)
            }
    }

    private func resizeGesture(corner: ResizeCorner, imageSize: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if activeCorner == nil {
                    activeCorner = corner
                    resizeStartScale = item.scale
                }
                let delta = value.translation
                let scaleDelta = corner.scaleFactor(
                    translation: CGSize(
                        width: delta.width / canvasScale,
                        height: delta.height / canvasScale
                    ),
                    imageSize: imageSize
                )
                item.scaleX = max(0.1, abs(resizeStartScale.width) + scaleDelta.width) * (resizeStartScale.width < 0 ? -1 : 1)
                item.scaleY = max(0.1, abs(resizeStartScale.height) + scaleDelta.height) * (resizeStartScale.height < 0 ? -1 : 1)
            }
            .onEnded { _ in
                let newScale = item.scale
                activeCorner = nil
                onScaleEnd(resizeStartScale, newScale)
            }
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if rotationStartAngle == 0 && currentRotationDelta == .zero {
                    rotationStartAngle = item.rotation
                }
                let angle = atan2(value.translation.width, -value.translation.height)
                currentRotationDelta = .radians(Double(angle))
            }
            .onEnded { _ in
                let newRotation = rotationStartAngle + currentRotationDelta.radians
                currentRotationDelta = .zero
                rotationStartAngle = 0
                onRotateEnd(item.rotation, newRotation)
            }
    }
}

// MARK: - Resize Corner

enum ResizeCorner: CaseIterable {
    case topLeft, topRight, bottomLeft, bottomRight

    func position(in size: CGSize) -> CGPoint {
        switch self {
        case .topLeft: return CGPoint(x: 0, y: 0)
        case .topRight: return CGPoint(x: size.width, y: 0)
        case .bottomLeft: return CGPoint(x: 0, y: size.height)
        case .bottomRight: return CGPoint(x: size.width, y: size.height)
        }
    }

    func scaleFactor(translation: CGSize, imageSize: CGSize) -> CGSize {
        let sx = translation.width / max(imageSize.width, 1)
        let sy = translation.height / max(imageSize.height, 1)
        switch self {
        case .topLeft: return CGSize(width: -sx, height: -sy)
        case .topRight: return CGSize(width: sx, height: -sy)
        case .bottomLeft: return CGSize(width: -sx, height: sy)
        case .bottomRight: return CGSize(width: sx, height: sy)
        }
    }
}

struct ResizeHandle: View {
    let corner: ResizeCorner
    let canvasScale: CGFloat

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 12 / canvasScale, height: 12 / canvasScale)
            .overlay {
                Circle().stroke(Color.accentColor, lineWidth: 1.5 / canvasScale)
            }
    }
}
