import SwiftUI

struct StickerRendererView: View {
    let sticker: StickerItem

    var body: some View {
        Group {
            switch sticker.style {
            case .washiTape(let patternIndex):
                washiTape(patternIndex: patternIndex)
            case .vintageStamp(let index):
                vintageStamp(index: index)
            case .postmark(let index):
                postmark(index: index)
            case .inkSplatter(let index):
                inkSplatter(index: index)
            case .flower(let index):
                flower(index: index)
            case .butterfly(let index):
                butterfly(index: index)
            case .star(let index):
                star(index: index)
            }
        }
    }

    // MARK: - Washi Tape

    @ViewBuilder
    private func washiTape(patternIndex: Int) -> some View {
        let colors: [Color] = [
            Color(red: 0.82, green: 0.55, blue: 0.60),
            Color(red: 0.55, green: 0.75, blue: 0.65),
            Color(red: 0.85, green: 0.75, blue: 0.50),
            Color(red: 0.60, green: 0.60, blue: 0.80),
            Color(red: 0.90, green: 0.65, blue: 0.50),
            Color(red: 0.65, green: 0.80, blue: 0.85),
        ]
        let color = colors[patternIndex % colors.count]

        RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(0.6))
            .frame(width: 60, height: 18)
            .overlay(
                // Torn edge effect
                HStack(spacing: 0) {
                    zigzagEdge
                    Spacer()
                    zigzagEdge
                }
            )
            .overlay(
                // Pattern stripes
                Canvas { context, size in
                    let stripeCount = patternIndex % 2 == 0 ? 5 : 3
                    let spacing = size.width / CGFloat(stripeCount + 1)
                    for i in 1...stripeCount {
                        let x = spacing * CGFloat(i)
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1)
                    }
                }
            )
    }

    private var zigzagEdge: some View {
        Canvas { context, size in
            var path = Path()
            let step: CGFloat = 3
            for i in stride(from: CGFloat(0), to: size.height, by: step) {
                let x: CGFloat = i.truncatingRemainder(dividingBy: step * 2) < step ? 0 : 2
                if i == 0 { path.move(to: CGPoint(x: x, y: i)) }
                else { path.addLine(to: CGPoint(x: x, y: i)) }
            }
            context.stroke(path, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
        }
        .frame(width: 3)
    }

    // MARK: - Vintage Stamp

    @ViewBuilder
    private func vintageStamp(index: Int) -> some View {
        let stampColors: [Color] = [
            Color(red: 0.65, green: 0.16, blue: 0.16),
            Color(red: 0.13, green: 0.37, blue: 0.31),
            Color(red: 0.25, green: 0.31, blue: 0.55),
            Color(red: 0.55, green: 0.27, blue: 0.52),
            Color(red: 0.70, green: 0.45, blue: 0.20),
        ]
        let color = stampColors[index % stampColors.count]
        let values = ["5¢", "10¢", "25¢", "1¢", "50¢"]

        ZStack {
            // Perforated border
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.95, green: 0.92, blue: 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
                        .foregroundStyle(color.opacity(0.6))
                        .padding(3)
                )

            VStack(spacing: 2) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                Text(values[index % values.count])
                    .font(.system(size: 10, weight: .bold, design: .serif))
                    .foregroundStyle(color)
            }
        }
        .frame(width: 52, height: 60)
    }

    // MARK: - Postmark

    @ViewBuilder
    private func postmark(index: Int) -> some View {
        let cities = ["PARIS", "TOKYO", "NYC", "LONDON"]
        let dates = ["MAR 1926", "JUL 1952", "DEC 1948", "SEP 1935"]

        ZStack {
            Circle()
                .strokeBorder(Color(red: 0.35, green: 0.25, blue: 0.20).opacity(0.6), lineWidth: 1.5)

            Circle()
                .strokeBorder(Color(red: 0.35, green: 0.25, blue: 0.20).opacity(0.4), lineWidth: 0.5)
                .padding(4)

            VStack(spacing: 1) {
                Text(cities[index % cities.count])
                    .font(.system(size: 8, weight: .bold, design: .serif))
                Text(dates[index % dates.count])
                    .font(.system(size: 5, design: .serif))
            }
            .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.20).opacity(0.7))

            // Wavy cancel lines
            Canvas { context, size in
                for lineY in stride(from: size.height * 0.3, through: size.height * 0.7, by: 4) {
                    var path = Path()
                    for x in stride(from: CGFloat(0), to: size.width, by: 1) {
                        let y = lineY + sin(x * 0.5) * 1.5
                        if x == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    context.stroke(path, with: .color(Color(red: 0.35, green: 0.25, blue: 0.20).opacity(0.15)), lineWidth: 0.5)
                }
            }
        }
        .frame(width: 56, height: 56)
        .rotationEffect(.degrees(Double(index) * 15 - 10))
    }

    // MARK: - Ink Splatter

    @ViewBuilder
    private func inkSplatter(index: Int) -> some View {
        let inkColors: [Color] = [
            .black.opacity(0.7),
            Color(red: 0.13, green: 0.13, blue: 0.40),
            Color(red: 0.55, green: 0.15, blue: 0.15),
            Color(red: 0.13, green: 0.35, blue: 0.13),
            Color(red: 0.35, green: 0.25, blue: 0.20),
        ]

        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let color = inkColors[index % inkColors.count]

            // Main blob
            let mainRadius = min(size.width, size.height) * 0.25
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - mainRadius,
                    y: center.y - mainRadius,
                    width: mainRadius * 2,
                    height: mainRadius * 1.6
                )),
                with: .color(color)
            )

            // Splatter drops
            let seed = index * 42
            for i in 0..<12 {
                let angle = Double(seed + i * 37) * 0.1
                let dist = mainRadius * (1.2 + CGFloat(i % 3) * 0.6)
                let dropX = center.x + cos(angle) * dist
                let dropY = center.y + sin(angle) * dist
                let dropR = CGFloat(2 + (i % 4))
                context.fill(
                    Path(ellipseIn: CGRect(x: dropX - dropR / 2, y: dropY - dropR / 2, width: dropR, height: dropR)),
                    with: .color(color.opacity(0.8))
                )
            }
        }
        .frame(width: 56, height: 56)
    }

    // MARK: - Flower

    @ViewBuilder
    private func flower(index: Int) -> some View {
        let petalColors: [Color] = [
            Color(red: 0.85, green: 0.30, blue: 0.35),
            Color(red: 1.0, green: 0.95, blue: 0.80),
            Color(red: 0.95, green: 0.75, blue: 0.20),
            Color(red: 0.70, green: 0.60, blue: 0.85),
            Color(red: 0.90, green: 0.55, blue: 0.65),
        ]
        let color = petalColors[index % petalColors.count]
        let petalCount = [5, 8, 12, 6, 7][index % 5]

        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            // Petals
            for i in 0..<petalCount {
                let angle = (2 * .pi / Double(petalCount)) * Double(i)
                let petalLength: CGFloat = 18
                let petalWidth: CGFloat = index == 2 ? 6 : 10
                let petalCenter = CGPoint(
                    x: center.x + cos(angle) * petalLength * 0.5,
                    y: center.y + sin(angle) * petalLength * 0.5
                )

                context.drawLayer { ctx in
                    let transform = CGAffineTransform(translationX: petalCenter.x, y: petalCenter.y)
                        .rotated(by: angle + .pi / 2)
                    ctx.concatenate(transform)
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: -petalWidth / 2, y: -petalLength / 2, width: petalWidth, height: petalLength)),
                        with: .color(color.opacity(0.85))
                    )
                }
            }

            // Center
            let centerR: CGFloat = 6
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - centerR, y: center.y - centerR, width: centerR * 2, height: centerR * 2)),
                with: .color(Color(red: 0.85, green: 0.65, blue: 0.20))
            )
        }
        .frame(width: 56, height: 56)
    }

    // MARK: - Butterfly

    @ViewBuilder
    private func butterfly(index: Int) -> some View {
        let wingColors: [Color] = [
            Color(red: 0.90, green: 0.55, blue: 0.20),
            Color(red: 0.45, green: 0.55, blue: 0.85),
            Color(red: 0.85, green: 0.35, blue: 0.55),
            Color(red: 0.55, green: 0.80, blue: 0.45),
        ]
        let color = wingColors[index % wingColors.count]

        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)

            // Wings
            for side in [-1.0, 1.0] {
                // Upper wing
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x + side * 4 - 12,
                        y: center.y - 20,
                        width: 24,
                        height: 18
                    )),
                    with: .color(color.opacity(0.8))
                )
                // Lower wing
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: center.x + side * 6 - 9,
                        y: center.y - 4,
                        width: 18,
                        height: 14
                    )),
                    with: .color(color.opacity(0.6))
                )
            }

            // Body
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 2, y: center.y - 16, width: 4, height: 24)),
                with: .color(Color(red: 0.25, green: 0.20, blue: 0.15))
            )

            // Antennae
            for side in [-1.0, 1.0] {
                var path = Path()
                path.move(to: CGPoint(x: center.x, y: center.y - 16))
                path.addQuadCurve(
                    to: CGPoint(x: center.x + side * 10, y: center.y - 24),
                    control: CGPoint(x: center.x + side * 4, y: center.y - 22)
                )
                context.stroke(path, with: .color(Color(red: 0.25, green: 0.20, blue: 0.15)), lineWidth: 0.8)
            }
        }
        .frame(width: 56, height: 56)
    }

    // MARK: - Star

    @ViewBuilder
    private func star(index: Int) -> some View {
        if let symbol = sticker.sfSymbol {
            Image(systemName: symbol)
                .font(.system(size: 32))
                .foregroundStyle(
                    index == 0 ? Color(red: 0.85, green: 0.65, blue: 0.20) :
                    index == 1 ? Color(red: 0.90, green: 0.75, blue: 0.30) :
                    index == 2 ? Color(red: 0.70, green: 0.55, blue: 0.20) :
                    Color(red: 0.85, green: 0.65, blue: 0.35)
                )
                .shadow(color: .black.opacity(0.1), radius: 1, y: 1)
        }
    }
}
