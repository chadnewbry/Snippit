import SwiftUI

/// Interactive canvas where users see the source image and use clipping tools.
struct ClippingCanvasView: View {
    @Bindable var viewModel: SmartClippingViewModel
    @State private var imageFrame: CGRect = .zero

    var body: some View {
        VStack(spacing: 0) {
            // Canvas area
            GeometryReader { geo in
                ZStack {
                    if let source = viewModel.sourceImage {
                        Image(uiImage: source)
                            .resizable()
                            .scaledToFit()
                            .background(GeometryReader { imgGeo in
                                Color.clear.preference(
                                    key: ImageFrameKey.self,
                                    value: imgGeo.frame(in: .named("canvas"))
                                )
                            })
                            .onPreferenceChange(ImageFrameKey.self) { imageFrame = $0 }
                    }

                    // Lasso overlay
                    if viewModel.activeTool == .lasso && !viewModel.lassoPoints.isEmpty {
                        LassoOverlayView(points: viewModel.lassoPoints, frame: imageFrame)
                    }

                    // Selected regions overlay
                    ForEach(viewModel.clippedRegions) { region in
                        ClippedRegionOverlay(region: region, imageFrame: imageFrame, sourceSize: viewModel.sourceImage?.size ?? .zero)
                    }

                    // Processing indicator
                    if viewModel.isProcessing {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                    }
                }
                .coordinateSpace(name: "canvas")
                .contentShape(Rectangle())
                .gesture(canvasGesture(in: geo))
            }

            // Tool bar
            ClippingToolbar(viewModel: viewModel)
        }
    }

    private func canvasGesture(in geo: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("canvas"))
            .onChanged { value in
                let normalized = normalizePoint(value.location, in: imageFrame)
                switch viewModel.activeTool {
                case .tapSelect:
                    break // Handled on ended
                case .lasso:
                    if !viewModel.isDrawingLasso {
                        viewModel.isDrawingLasso = true
                        viewModel.lassoPoints = []
                    }
                    viewModel.lassoPoints.append(normalized)
                case .refine:
                    break // TODO: brush stroke
                }
            }
            .onEnded { value in
                let normalized = normalizePoint(value.location, in: imageFrame)
                switch viewModel.activeTool {
                case .tapSelect:
                    Task { await viewModel.tapToSelect(at: normalized) }
                case .lasso:
                    Task { await viewModel.completeLasso() }
                case .refine:
                    break
                }
            }
    }

    private func normalizePoint(_ point: CGPoint, in frame: CGRect) -> CGPoint {
        guard frame.width > 0, frame.height > 0 else { return .zero }
        return CGPoint(
            x: (point.x - frame.minX) / frame.width,
            y: (point.y - frame.minY) / frame.height
        )
    }
}

private struct ImageFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

/// Draws the lasso path as the user draws.
struct LassoOverlayView: View {
    let points: [CGPoint]
    let frame: CGRect

    var body: some View {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: denormalize(first))
            for pt in points.dropFirst() {
                path.addLine(to: denormalize(pt))
            }
        }
        .stroke(Color.yellow, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        .allowsHitTesting(false)
    }

    private func denormalize(_ pt: CGPoint) -> CGPoint {
        CGPoint(
            x: frame.minX + pt.x * frame.width,
            y: frame.minY + pt.y * frame.height
        )
    }
}

/// Shows a highlight overlay for a detected/clipped region.
struct ClippedRegionOverlay: View {
    let region: SmartClippingViewModel.ClippedRegion
    let imageFrame: CGRect
    let sourceSize: CGSize

    var body: some View {
        let rect = denormalizedRect
        RoundedRectangle(cornerRadius: 4)
            .stroke(Color.cyan, lineWidth: 2)
            .background(Color.cyan.opacity(0.15))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .allowsHitTesting(false)
    }

    private var denormalizedRect: CGRect {
        guard sourceSize.width > 0, sourceSize.height > 0 else { return .zero }
        let scaleX = imageFrame.width / sourceSize.width
        let scaleY = imageFrame.height / sourceSize.height
        return CGRect(
            x: imageFrame.minX + region.boundingBox.origin.x * scaleX,
            y: imageFrame.minY + region.boundingBox.origin.y * scaleY,
            width: region.boundingBox.width * scaleX,
            height: region.boundingBox.height * scaleY
        )
    }
}

#Preview {
    ClippingCanvasView(viewModel: SmartClippingViewModel())
}
