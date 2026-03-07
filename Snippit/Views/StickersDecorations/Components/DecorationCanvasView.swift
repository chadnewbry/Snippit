import SwiftUI

struct DecorationCanvasView: View {
    @Binding var placedDecorations: [PlacedDecoration]
    @State private var draggedItem: UUID?

    var body: some View {
        ZStack {
            // Kraft paper background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.95, green: 0.91, blue: 0.82))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(red: 0.82, green: 0.75, blue: 0.62), lineWidth: 2, antialiased: true)
                )
                .overlay(paperNoiseOverlay)

            // Placed decorations
            ForEach(placedDecorations) { decoration in
                DecorationItemView(decoration: decoration)
                    .position(decoration.position)
                    .rotationEffect(.radians(decoration.rotation))
                    .scaleEffect(decoration.scale)
                    .gesture(dragGesture(for: decoration.id))
            }

            if placedDecorations.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(red: 0.70, green: 0.62, blue: 0.50))
                    Text("Tap stickers, draw, or stamp shapes")
                        .font(.subheadline)
                        .foregroundStyle(Color(red: 0.60, green: 0.52, blue: 0.40))
                }
            }
        }
        .padding(12)
        .accessibilityIdentifier("decorationCanvas")
    }

    private var paperNoiseOverlay: some View {
        Canvas { context, size in
            // Subtle paper grain texture
            for _ in 0..<200 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let opacity = Double.random(in: 0.02...0.06)
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1.5, height: 1.5)),
                    with: .color(.brown.opacity(opacity))
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    private func dragGesture(for id: UUID) -> some Gesture {
        DragGesture()
            .onChanged { value in
                guard let idx = placedDecorations.firstIndex(where: { $0.id == id }) else { return }
                placedDecorations[idx].position = value.location
            }
    }
}
