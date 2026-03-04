import SwiftUI

/// Renders a single text element on the canvas with all styling applied.
struct TextElementView: View {
    @Bindable var element: TextElement
    let isSelected: Bool
    var onTap: () -> Void = {}

    var body: some View {
        Group {
            if element.isRansomNote {
                RansomNoteView(element: element)
            } else if element.isTextOnPaper {
                TextOnPaperView(element: element)
            } else {
                styledText
            }
        }
        .opacity(element.opacity)
        .scaleEffect(CGSize(width: element.scaleX, height: element.scaleY))
        .rotationEffect(.radians(element.rotation))
        .position(element.position)
        .onTapGesture { onTap() }
        .overlay {
            if isSelected {
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 3]))
                    .foregroundStyle(.blue)
                    .padding(-8)
                    .position(element.position)
            }
        }
    }

    private var styledText: some View {
        Text(element.text)
            .font(.custom(element.fontName, size: element.fontSize))
            .tracking(element.letterSpacing)
            .foregroundStyle(element.color)
            .modifier(TextOutlineModifier(element: element))
            .modifier(TextShadowModifier(element: element))
    }
}

private struct TextOutlineModifier: ViewModifier {
    let element: TextElement

    func body(content: Content) -> some View {
        if let outlineHex = element.outlineColorHex, element.outlineWidth > 0,
           let outlineColor = Color(hex: outlineHex) {
            content
                .overlay {
                    Text(element.text)
                        .font(.custom(element.fontName, size: element.fontSize))
                        .tracking(element.letterSpacing)
                        .foregroundStyle(outlineColor)
                        .mask {
                            Text(element.text)
                                .font(.custom(element.fontName, size: element.fontSize))
                                .tracking(element.letterSpacing)
                        }
                }
                .shadow(color: outlineColor, radius: element.outlineWidth)
        } else {
            content
        }
    }
}

private struct TextShadowModifier: ViewModifier {
    let element: TextElement

    func body(content: Content) -> some View {
        if element.shadowRadius > 0 {
            let shadowColor = element.shadowColorHex.flatMap { Color(hex: $0) } ?? .black.opacity(0.5)
            content.shadow(
                color: shadowColor,
                radius: element.shadowRadius,
                x: element.shadowOffsetX,
                y: element.shadowOffsetY
            )
        } else {
            content
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        TextElementView(element: .preview, isSelected: true)
    }
}
