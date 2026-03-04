import SwiftUI
import SwiftData

/// Text & Typography tools view - add and edit text elements on the canvas.
struct TextTypographyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var textElements: [TextElement]
    @State private var selectedElement: TextElement?
    @State private var showStyleEditor = false
    @State private var dragOffset: CGSize = .zero
    @State private var activeGesture: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                // Canvas background
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                    .onTapGesture { location in
                        addTextElement(at: location)
                    }

                // Text elements
                ForEach(textElements.sorted(by: { $0.zIndex < $1.zIndex })) { element in
                    TextElementView(
                        element: element,
                        isSelected: selectedElement?.id == element.id
                    ) {
                        selectedElement = element
                        showStyleEditor = true
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                element.positionX = value.location.x
                                element.positionY = value.location.y
                            }
                    )
                    .simultaneousGesture(
                        RotationGesture()
                            .onChanged { angle in
                                element.rotation = angle.radians
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                element.scaleX = scale
                                element.scaleY = scale
                            }
                    )
                }
            }
            .navigationTitle("Text & Typography")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            addTextElement(at: CGPoint(x: 200, y: 400))
                        } label: {
                            Label("Add Text", systemImage: "textformat")
                        }

                        Button {
                            addRansomNote(at: CGPoint(x: 200, y: 400))
                        } label: {
                            Label("Ransom Note", systemImage: "scissors")
                        }

                        Button {
                            addPaperText(at: CGPoint(x: 200, y: 400))
                        } label: {
                            Label("Text on Paper", systemImage: "doc.text")
                        }

                        if selectedElement != nil {
                            Divider()
                            Button(role: .destructive) {
                                deleteSelected()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    if selectedElement != nil {
                        Button {
                            showStyleEditor = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                    }
                }
            }
            .sheet(isPresented: $showStyleEditor) {
                if let element = selectedElement {
                    NavigationStack {
                        TextStyleEditorView(element: element)
                            .navigationTitle("Style Text")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") { showStyleEditor = false }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .accessibilityIdentifier("textTypographyTab")
    }

    private func addTextElement(at point: CGPoint) {
        let element = TextElement(
            text: "Tap to edit",
            fontName: "Georgia",
            fontSize: 32,
            position: point,
            zIndex: textElements.count,
            colorHex: "#FFFFFF"
        )
        modelContext.insert(element)
        selectedElement = element
        showStyleEditor = true
    }

    private func addRansomNote(at point: CGPoint) {
        let element = TextElement(
            text: "RANSOM",
            fontName: "Helvetica-Bold",
            fontSize: 42,
            position: point,
            zIndex: textElements.count,
            colorHex: "#FFFFFF",
            isRansomNote: true
        )
        modelContext.insert(element)
        selectedElement = element
        showStyleEditor = true
    }

    private func addPaperText(at point: CGPoint) {
        let element = TextElement(
            text: "paper note",
            fontName: "AmericanTypewriter",
            fontSize: 24,
            position: point,
            zIndex: textElements.count,
            colorHex: "#333333",
            isTextOnPaper: true
        )
        modelContext.insert(element)
        selectedElement = element
        showStyleEditor = true
    }

    private func deleteSelected() {
        if let element = selectedElement {
            modelContext.delete(element)
            selectedElement = nil
        }
    }
}

#Preview {
    TextTypographyView()
        .modelContainer(for: TextElement.self, inMemory: true)
}
