import SwiftUI

struct DoodleToolView: View {
    let onStrokeComplete: (DoodleStroke) -> Void

    @State private var selectedBrush: BrushType = .pen
    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 2
    @State private var currentStroke: DoodleStroke?
    @State private var strokes: [DoodleStroke] = []

    var body: some View {
        VStack(spacing: 12) {
            // Drawing canvas
            drawingCanvas
                .frame(height: 120)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.98, green: 0.96, blue: 0.92))
                        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                )
                .padding(.horizontal, 12)

            // Brush type selector
            HStack(spacing: 12) {
                ForEach(BrushType.allCases) { brush in
                    Button {
                        selectedBrush = brush
                        lineWidth = brush.defaultWidth
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: brush.icon)
                                .font(.title3)
                            Text(brush.rawValue)
                                .font(.system(size: 9))
                        }
                        .frame(width: 56, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedBrush == brush
                                    ? Color(red: 0.82, green: 0.55, blue: 0.60).opacity(0.3)
                                    : Color(.tertiarySystemGroupedBackground))
                        )
                        .foregroundStyle(selectedBrush == brush
                            ? Color(red: 0.65, green: 0.16, blue: 0.16)
                            : .secondary)
                    }
                    .accessibilityIdentifier("brush_\(brush.rawValue)")
                }

                Spacer()

                // Clear button
                Button {
                    strokes.removeAll()
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("clearDoodle")
            }
            .padding(.horizontal, 12)

            // Color palette & width
            HStack(spacing: 8) {
                ForEach(Array(DoodleColorPalette.scrapbookColors.enumerated()), id: \.offset) { idx, color in
                    Button {
                        selectedColor = color
                    } label: {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: selectedColor == color ? 2 : 0)
                            )
                            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                    }
                    .accessibilityIdentifier("doodleColor_\(idx)")
                }

                Spacer()

                // Width slider
                Slider(value: $lineWidth, in: 1...30, step: 1)
                    .frame(width: 80)
                    .tint(Color(red: 0.70, green: 0.45, blue: 0.20))
                    .accessibilityIdentifier("brushWidthSlider")
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 8)
        .accessibilityIdentifier("doodleToolView")
    }

    private var drawingCanvas: some View {
        Canvas { context, size in
            for stroke in strokes {
                drawStroke(stroke, in: &context)
            }
            if let current = currentStroke {
                drawStroke(current, in: &context)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if currentStroke == nil {
                        currentStroke = DoodleStroke(
                            brush: selectedBrush,
                            color: selectedColor,
                            lineWidth: lineWidth
                        )
                    }
                    currentStroke?.points.append(value.location)
                }
                .onEnded { _ in
                    if let stroke = currentStroke, stroke.points.count > 1 {
                        strokes.append(stroke)
                        onStrokeComplete(stroke)
                    }
                    currentStroke = nil
                }
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func drawStroke(_ stroke: DoodleStroke, in context: inout GraphicsContext) {
        guard stroke.points.count > 1 else { return }

        var path = Path()
        path.move(to: stroke.points[0])
        for i in 1..<stroke.points.count {
            path.addLine(to: stroke.points[i])
        }

        context.stroke(
            path,
            with: .color(stroke.color.opacity(stroke.brush.opacity)),
            style: StrokeStyle(
                lineWidth: stroke.lineWidth,
                lineCap: stroke.brush.lineCap,
                lineJoin: .round
            )
        )
    }
}
