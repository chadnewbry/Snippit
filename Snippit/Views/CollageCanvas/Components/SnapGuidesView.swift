import SwiftUI

struct SnapGuidesView: View {
    let horizontalGuide: CGFloat?
    let verticalGuide: CGFloat?
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            if let h = horizontalGuide {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addLine(to: CGPoint(x: canvasSize.width, y: h))
                }
                .stroke(Color.accentColor.opacity(0.6), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
            }

            if let v = verticalGuide {
                Path { path in
                    path.move(to: CGPoint(x: v, y: 0))
                    path.addLine(to: CGPoint(x: v, y: canvasSize.height))
                }
                .stroke(Color.accentColor.opacity(0.6), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
            }
        }
        .allowsHitTesting(false)
    }
}
