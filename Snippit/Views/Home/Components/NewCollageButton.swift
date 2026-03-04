import SwiftData
import SwiftUI

struct NewCollageButton: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingSizeSheet = false

    var body: some View {
        Button {
            showingSizeSheet = true
        } label: {
            Label("New Collage", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.purple)
        .accessibilityIdentifier("newCollageButton")
        .sheet(isPresented: $showingSizeSheet) {
            CanvasSizePicker { size in
                let project = CollageProject(
                    name: "Untitled Collage",
                    canvasSize: size.dimensions
                )
                modelContext.insert(project)
                showingSizeSheet = false
            }
            .presentationDetents([.medium])
        }
    }
}

struct CanvasSizePicker: View {
    let onSelect: (CanvasSize) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(CanvasSize.allCases) { size in
                        Button {
                            onSelect(size)
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: size.icon)
                                    .font(.title2)
                                    .frame(height: 40)
                                Text(size.rawValue)
                                    .font(.subheadline.weight(.medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("canvasSize-\(size.rawValue)")
                    }
                }
                .padding()
            }
            .navigationTitle("Canvas Size")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
