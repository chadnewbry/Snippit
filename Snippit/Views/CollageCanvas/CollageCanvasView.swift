import SwiftData
import SwiftUI

struct CollageCanvasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollageProject.modifiedAt, order: .reverse)
    private var projects: [CollageProject]

    @State private var viewModel = CanvasViewModel()
    @State private var showProjectPicker = false
    @State private var showEffectsPanel = false

    private var activeProject: CollageProject? { projects.first }

    var body: some View {
        NavigationStack {
            Group {
                if let project = activeProject {
                    canvasEditor(project: project)
                } else {
                    emptyState
                }
            }
            .navigationTitle("Canvas")
            .navigationBarTitleDisplayMode(.inline)
        }
        .accessibilityIdentifier("collageCanvasTab")
    }

    // MARK: - Canvas Editor

    @ViewBuilder
    private func canvasEditor(project: CollageProject) -> some View {
        VStack(spacing: 0) {
            CanvasToolbarView(
                viewModel: viewModel,
                project: project,
                onDelete: {
                    if let selected = viewModel.selectedItem {
                        viewModel.removeItem(selected, from: project)
                        showEffectsPanel = false
                    }
                }
            )

            ZStack(alignment: .bottom) {
                // Pasteboard-style surrounding area
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                canvasContent(project: project)

                // Paper effects control panel
                if showEffectsPanel, let selected = viewModel.selectedItem {
                    PaperEffectsControlPanel(item: selected)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: showEffectsPanel)

            HStack(spacing: 0) {
                // Effects toggle button
                Button {
                    withAnimation {
                        showEffectsPanel.toggle()
                    }
                } label: {
                    Label("Effects", systemImage: "wand.and.stars")
                        .font(.caption)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .disabled(viewModel.selectedItem == nil)

                CanvasIngredientsTrayView { item in
                    dropIngredient(item, into: project)
                }
            }
        }
        .onChange(of: viewModel.selectedItem?.id) { _, newValue in
            if newValue == nil {
                showEffectsPanel = false
            }
        }
    }

    @ViewBuilder
    private func canvasContent(project: CollageProject) -> some View {
        let canvasSize = project.canvasSize

        GeometryReader { geo in
            let fitScale = min(
                geo.size.width * 0.9 / canvasSize.width,
                geo.size.height * 0.9 / canvasSize.height
            )

            ZStack {
                // Canvas rectangle
                ZStack {
                    // Background
                    CanvasBackgroundView(style: viewModel.background, size: canvasSize)

                    // Grid overlay
                    if viewModel.showGrid {
                        GridOverlayView(canvasSize: canvasSize, spacing: 40)
                    }

                    // Snap guides
                    SnapGuidesView(
                        horizontalGuide: viewModel.horizontalGuide,
                        verticalGuide: viewModel.verticalGuide,
                        canvasSize: canvasSize
                    )

                    // Items
                    ForEach(viewModel.sortedLayers(of: project)) { item in
                        CanvasItemView(
                            item: item,
                            isSelected: viewModel.selectedItem?.id == item.id,
                            canvasScale: viewModel.canvasScale * fitScale,
                            onSelect: { viewModel.selectedItem = item },
                            onDragEnd: { oldPos, newPos in
                                let snapped = viewModel.snapPosition(newPos, in: project)
                                viewModel.moveItem(item, to: snapped, from: oldPos)
                                viewModel.clearSnapGuides()
                            },
                            onScaleEnd: { oldScale, newScale in
                                viewModel.scaleItem(item, to: newScale, from: oldScale)
                            },
                            onRotateEnd: { oldRot, newRot in
                                viewModel.rotateItem(item, to: newRot, from: oldRot)
                            }
                        )
                    }
                }
                .frame(width: canvasSize.width, height: canvasSize.height)
                .clipShape(Rectangle())
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .scaleEffect(fitScale * viewModel.canvasScale)
            .offset(viewModel.canvasOffset)
            .gesture(canvasGestures)
            .onTapGesture {
                viewModel.selectedItem = nil
            }
            .dropDestination(for: Data.self) { items, location in
                for data in items {
                    let item = ClippedItem(
                        imageData: data,
                        position: CGPoint(
                            x: canvasSize.width / 2,
                            y: canvasSize.height / 2
                        )
                    )
                    viewModel.addItem(item, to: project)
                }
                return !items.isEmpty
            }
        }
    }

    // MARK: - Canvas Gestures (pinch-to-zoom + pan)

    private var canvasGestures: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    viewModel.canvasScale = max(0.3, min(5.0, value))
                }
                .onEnded { value in
                    viewModel.canvasScale = max(0.3, min(5.0, value))
                },
            DragGesture(minimumDistance: 5)
                .onChanged { value in
                    viewModel.canvasOffset = value.translation
                }
        )
    }

    // MARK: - Ingredient Drop

    private func dropIngredient(_ item: ClippedItem, into project: CollageProject) {
        let canvasItem = ClippedItem(
            imageData: item.imageData,
            position: CGPoint(
                x: project.canvasWidth / 2 + CGFloat.random(in: -50...50),
                y: project.canvasHeight / 2 + CGFloat.random(in: -50...50)
            ),
            rotation: Double.random(in: -0.1...0.1),
            rippedEdgeSeed: item.rippedEdgeSeed,
            rippedEdgeRoughness: item.rippedEdgeRoughness,
            edgeStyle: item.edgeStyle,
            craftOverlay: item.craftOverlay,
            agingEffect: item.agingEffect,
            paperCurl: item.paperCurl,
            fiberDetailIntensity: item.fiberDetailIntensity
        )
        viewModel.addItem(canvasItem, to: project)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.on.rectangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Projects Yet")
                .font(.title3.weight(.semibold))
            Text("Create a project from the Home tab to start composing")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    CollageCanvasView()
        .modelContainer(for: CollageProject.self, inMemory: true)
}
