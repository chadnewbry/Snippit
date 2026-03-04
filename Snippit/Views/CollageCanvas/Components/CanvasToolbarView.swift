import SwiftUI

struct CanvasToolbarView: View {
    @Bindable var viewModel: CanvasViewModel
    let project: CollageProject
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Undo / Redo
            Button { viewModel.undo() } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(!viewModel.canUndo)
            .accessibilityIdentifier("undoButton")

            Button { viewModel.redo() } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(!viewModel.canRedo)
            .accessibilityIdentifier("redoButton")

            Divider().frame(height: 20)

            // Grid toggle
            Button {
                viewModel.showGrid.toggle()
            } label: {
                Image(systemName: viewModel.showGrid ? "grid" : "grid.circle")
            }
            .accessibilityIdentifier("gridToggle")

            Divider().frame(height: 20)

            if let selected = viewModel.selectedItem {
                // Layer ordering
                Button { viewModel.bringForward(selected, in: project) } label: {
                    Image(systemName: "square.2.layers.3d.top.filled")
                }
                .accessibilityIdentifier("bringForwardButton")

                Button { viewModel.sendBackward(selected, in: project) } label: {
                    Image(systemName: "square.2.layers.3d.bottom.filled")
                }
                .accessibilityIdentifier("sendBackwardButton")

                Divider().frame(height: 20)

                // Flip
                Button { viewModel.flipHorizontal(selected) } label: {
                    Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                }
                .accessibilityIdentifier("flipHButton")

                Button { viewModel.flipVertical(selected) } label: {
                    Image(systemName: "arrow.up.and.down.righttriangle.up.righttriangle.down")
                }
                .accessibilityIdentifier("flipVButton")

                Divider().frame(height: 20)

                // Delete
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                }
                .accessibilityIdentifier("deleteItemButton")
            }

            Spacer()

            // Background picker
            Menu {
                ForEach(CanvasBackgroundStyle.allCases) { bg in
                    Button {
                        viewModel.background = bg
                    } label: {
                        Label(bg.rawValue, systemImage: bg.icon)
                    }
                }
            } label: {
                Image(systemName: "paintpalette")
            }
            .accessibilityIdentifier("backgroundPicker")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }
}
