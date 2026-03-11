import SwiftUI

/// Renders a paper curl effect at corners of a clipped item.
struct PaperCurlView: View {
    let curl: PaperCurlEffect
    let itemSize: CGSize

    var body: some View {
        if curl.enabled {
            ZStack {
                // Top-left curl
                if curl.cornerIntensity.count > 0, curl.cornerIntensity[0] > 0 {
                    cornerCurl(intensity: curl.cornerIntensity[0])
                        .position(x: 0, y: 0)
                }
                // Top-right curl
                if curl.cornerIntensity.count > 1, curl.cornerIntensity[1] > 0 {
                    cornerCurl(intensity: curl.cornerIntensity[1])
                        .scaleEffect(x: -1, y: 1)
                        .position(x: itemSize.width, y: 0)
                }
                // Bottom-left curl
                if curl.cornerIntensity.count > 2, curl.cornerIntensity[2] > 0 {
                    cornerCurl(intensity: curl.cornerIntensity[2])
                        .scaleEffect(x: 1, y: -1)
                        .position(x: 0, y: itemSize.height)
                }
                // Bottom-right curl
                if curl.cornerIntensity.count > 3, curl.cornerIntensity[3] > 0 {
                    cornerCurl(intensity: curl.cornerIntensity[3])
                        .scaleEffect(x: -1, y: -1)
                        .position(x: itemSize.width, y: itemSize.height)
                }
            }
            .frame(width: itemSize.width, height: itemSize.height)
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private func cornerCurl(intensity: Double) -> some View {
        let curlSize = min(itemSize.width, itemSize.height) * 0.15 * CGFloat(intensity)

        Canvas { context, size in
            // Shadow under the curl
            var shadowPath = Path()
            shadowPath.move(to: .zero)
            shadowPath.addLine(to: CGPoint(x: curlSize, y: 0))
            shadowPath.addQuadCurve(
                to: CGPoint(x: 0, y: curlSize),
                control: CGPoint(x: curlSize * 0.4, y: curlSize * 0.4)
            )
            shadowPath.closeSubpath()

            context.drawLayer { ctx in
                ctx.addFilter(.shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 1))
                ctx.fill(shadowPath, with: .color(.white))
            }

            // Curl triangle with gradient to simulate the folded paper
            var curlPath = Path()
            curlPath.move(to: .zero)
            curlPath.addLine(to: CGPoint(x: curlSize, y: 0))
            curlPath.addQuadCurve(
                to: CGPoint(x: 0, y: curlSize),
                control: CGPoint(x: curlSize * 0.35, y: curlSize * 0.35)
            )
            curlPath.closeSubpath()

            context.fill(
                curlPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color(white: 0.92),
                        Color(white: 0.85),
                        Color(white: 0.78)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: curlSize, y: curlSize)
                )
            )
        }
        .frame(width: curlSize, height: curlSize)
    }
}
