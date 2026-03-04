import SwiftUI

/// Renders text in ransom note style - each letter gets a different font, size, color, and rotation.
struct RansomNoteView: View {
    let element: TextElement

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(element.text.enumerated()), id: \.offset) { index, char in
                let seed = element.paperSeed &+ index
                let letter = RansomLetter(character: char, seed: seed, baseSize: element.fontSize)
                
                Text(String(char))
                    .font(.custom(letter.fontName, size: letter.fontSize))
                    .foregroundStyle(letter.color)
                    .rotationEffect(.degrees(letter.rotationDegrees))
                    .background(
                        RoundedRectangle(cornerRadius: 2)
                            .fill(letter.backgroundColor)
                            .padding(-3)
                    )
                    .padding(.horizontal, 1)
            }
        }
    }
}

/// Deterministic per-letter styling for ransom note mode.
private struct RansomLetter {
    let fontName: String
    let fontSize: CGFloat
    let color: Color
    let backgroundColor: Color
    let rotationDegrees: Double

    private static let ransomColors: [Color] = [
        .white, .black, .red, .blue, .yellow, .green, .orange, .purple, .pink
    ]

    private static let ransomBackgrounds: [Color] = [
        .clear, .white, .yellow.opacity(0.6), .white.opacity(0.8),
        .orange.opacity(0.3), .clear, .clear, .white.opacity(0.5)
    ]

    init(character: Character, seed: Int, baseSize: Double) {
        var rng = SeededRNG(seed: UInt64(abs(seed)))

        let fonts = FontLibrary.availableFonts
        let fontEntry = fonts[Int(rng.next() % UInt64(max(fonts.count, 1)))]
        self.fontName = fontEntry.name

        let sizeVariation = Double(rng.next() % 40) - 15 // -15 to +25
        self.fontSize = max(14, baseSize + sizeVariation)

        let colorIdx = Int(rng.next() % UInt64(Self.ransomColors.count))
        self.color = Self.ransomColors[colorIdx]

        let bgIdx = Int(rng.next() % UInt64(Self.ransomBackgrounds.count))
        self.backgroundColor = Self.ransomBackgrounds[bgIdx]

        let rot = Double(rng.next() % 30) - 15 // -15 to +15 degrees
        self.rotationDegrees = rot
    }
}

private struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

#Preview {
    RansomNoteView(element: TextElement(
        text: "RANSOM NOTE",
        fontSize: 36,
        isRansomNote: true,
        paperSeed: 42
    ))
    .padding()
    .background(Color.gray.opacity(0.2))
}
