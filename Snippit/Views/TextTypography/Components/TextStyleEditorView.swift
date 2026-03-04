import SwiftUI

/// Editor panel for text styling: color, outline, shadow, opacity, letter spacing.
struct TextStyleEditorView: View {
    @Bindable var element: TextElement
    @State private var showFontPicker = false
    @State private var textColor: Color = .white
    @State private var outlineColor: Color = .black
    @State private var shadowColor: Color = .black

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Text input
                Section {
                    TextField("Enter text", text: $element.text, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                } header: {
                    sectionHeader("Text")
                }

                // Font
                Section {
                    Button {
                        showFontPicker = true
                    } label: {
                        HStack {
                            Text("Aa")
                                .font(.custom(element.fontName, size: 20))
                            Text(element.fontName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.ultraThinMaterial))
                    }
                    .foregroundStyle(.primary)

                    HStack {
                        Text("Size")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $element.fontSize, in: 12...120, step: 1)
                        Text("\(Int(element.fontSize))")
                            .font(.caption.monospacedDigit())
                            .frame(width: 36)
                    }
                } header: {
                    sectionHeader("Font")
                }

                // Color
                Section {
                    ColorPicker("Text Color", selection: $textColor, supportsOpacity: false)
                        .onChange(of: textColor) { _, newValue in
                            element.colorHex = newValue.hexString
                        }
                } header: {
                    sectionHeader("Color")
                }

                // Opacity & Spacing
                Section {
                    HStack {
                        Text("Opacity")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $element.opacity, in: 0.1...1.0)
                        Text("\(Int(element.opacity * 100))%")
                            .font(.caption.monospacedDigit())
                            .frame(width: 40)
                    }

                    HStack {
                        Text("Letter Spacing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $element.letterSpacing, in: -5...20, step: 0.5)
                        Text(String(format: "%.1f", element.letterSpacing))
                            .font(.caption.monospacedDigit())
                            .frame(width: 36)
                    }
                } header: {
                    sectionHeader("Spacing & Opacity")
                }

                // Outline
                Section {
                    HStack {
                        Text("Width")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $element.outlineWidth, in: 0...8, step: 0.5)
                        Text(String(format: "%.1f", element.outlineWidth))
                            .font(.caption.monospacedDigit())
                            .frame(width: 36)
                    }

                    if element.outlineWidth > 0 {
                        ColorPicker("Outline Color", selection: $outlineColor, supportsOpacity: false)
                            .onChange(of: outlineColor) { _, newValue in
                                element.outlineColorHex = newValue.hexString
                            }
                    }
                } header: {
                    sectionHeader("Outline / Stroke")
                }

                // Shadow
                Section {
                    HStack {
                        Text("Radius")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $element.shadowRadius, in: 0...20, step: 0.5)
                        Text(String(format: "%.1f", element.shadowRadius))
                            .font(.caption.monospacedDigit())
                            .frame(width: 36)
                    }

                    if element.shadowRadius > 0 {
                        HStack {
                            Text("Offset X")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $element.shadowOffsetX, in: -10...10, step: 0.5)
                        }
                        HStack {
                            Text("Offset Y")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $element.shadowOffsetY, in: -10...10, step: 0.5)
                        }
                        ColorPicker("Shadow Color", selection: $shadowColor, supportsOpacity: true)
                            .onChange(of: shadowColor) { _, newValue in
                                element.shadowColorHex = newValue.hexString
                            }
                    }
                } header: {
                    sectionHeader("Shadow")
                }

                // Modes
                Section {
                    Toggle("Ransom Note Mode", isOn: $element.isRansomNote)
                        .onChange(of: element.isRansomNote) { _, on in
                            if on { element.isTextOnPaper = false }
                        }
                    
                    Toggle("Text on Paper", isOn: $element.isTextOnPaper)
                        .onChange(of: element.isTextOnPaper) { _, on in
                            if on { element.isRansomNote = false }
                        }

                    if element.isTextOnPaper {
                        HStack {
                            Text("Paper Roughness")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $element.paperRoughness, in: 0.1...1.0)
                        }
                    }
                } header: {
                    sectionHeader("Special Modes")
                }
            }
            .padding()
        }
        .sheet(isPresented: $showFontPicker) {
            NavigationStack {
                FontPickerView(selectedFontName: $element.fontName)
                    .navigationTitle("Choose Font")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showFontPicker = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear {
            textColor = element.color
            outlineColor = element.outlineColorHex.flatMap { Color(hex: $0) } ?? .black
            shadowColor = element.shadowColorHex.flatMap { Color(hex: $0) } ?? .black
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

#Preview {
    TextStyleEditorView(element: .preview)
}
