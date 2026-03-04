import SwiftUI

/// Full-screen magazine reader with page-turn animation, swipe navigation, and pinch-to-zoom.
struct MagazineReaderView: View {
    let magazine: MagazineItem
    let magazineManager: MagazineManager
    let historyManager: BrowsingHistoryManager

    @State private var pages: [MagazinePage] = []
    @State private var currentPageIndex = 0
    @State private var isLoading = true
    @State private var error: Error?
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false

    // Zoom state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading pages...")
                        .tint(.white)
                        .foregroundStyle(.white)
                } else if let error {
                    ContentUnavailableView(
                        "Failed to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                } else if !pages.isEmpty {
                    pageContent(in: geometry)
                }
            }
        }
        .navigationTitle(magazine.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    // Bookmark button
                    if !pages.isEmpty && currentPageIndex < pages.count {
                        Button {
                            historyManager.toggleBookmark(
                                magazine: magazine,
                                page: pages[currentPageIndex]
                            )
                        } label: {
                            Image(systemName: historyManager.isBookmarked(
                                magazineIdentifier: magazine.identifier,
                                pageNumber: currentPageIndex
                            ) ? "bookmark.fill" : "bookmark")
                        }
                        .accessibilityIdentifier("bookmarkButton")
                    }

                    // Page indicator
                    Text("\(currentPageIndex + 1) / \(pages.count)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }

            ToolbarItem(placement: .bottomBar) {
                useThisPageButton
            }
        }
        .task {
            historyManager.recordBrowsed(magazine)
            await loadPages()
        }
    }

    // MARK: - Page Content

    @ViewBuilder
    private func pageContent(in geometry: GeometryProxy) -> some View {
        let size = geometry.size

        ZStack {
            // Current page
            pageView(for: currentPageIndex, size: size)
                .offset(x: dragOffset)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { value in
                            lastScale = max(1.0, min(scale, 4.0))
                            scale = lastScale
                            if scale < 1.0 {
                                withAnimation(.spring(response: 0.3)) {
                                    scale = 1.0
                                    lastScale = 1.0
                                }
                            }
                        }
                )
                .simultaneousGesture(
                    scale <= 1.0 ?
                    DragGesture(minimumDistance: 30)
                        .onChanged { value in
                            if !isAnimating {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            handleSwipe(value.translation.width, velocity: value.predictedEndTranslation.width, pageWidth: size.width)
                        }
                    : nil
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring(response: 0.3)) {
                        if scale > 1.0 {
                            scale = 1.0
                            lastScale = 1.0
                        } else {
                            scale = 2.5
                            lastScale = 2.5
                        }
                    }
                }

            // Page turn shadow overlay
            if dragOffset != 0 {
                pageTurnShadow(offset: dragOffset, pageWidth: size.width)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func pageView(for index: Int, size: CGSize) -> some View {
        if index >= 0 && index < pages.count {
            AsyncImage(url: pages[index].imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.5))
                        .frame(width: size.width, height: size.height)
                case .empty:
                    ProgressView()
                        .tint(.white)
                        .frame(width: size.width, height: size.height)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }

    /// Realistic page-turn shadow effect.
    private func pageTurnShadow(offset: CGFloat, pageWidth: CGFloat) -> some View {
        let progress = abs(offset) / pageWidth
        let shadowOpacity = min(progress * 0.4, 0.3)

        return HStack(spacing: 0) {
            if offset > 0 {
                Spacer()
                LinearGradient(
                    colors: [.black.opacity(shadowOpacity), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)
            } else {
                LinearGradient(
                    colors: [.clear, .black.opacity(shadowOpacity)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 30)
                Spacer()
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Navigation

    private func handleSwipe(_ offset: CGFloat, velocity: CGFloat, pageWidth: CGFloat) {
        let threshold = pageWidth * 0.25
        let shouldAdvance = offset < -threshold || velocity < -pageWidth
        let shouldGoBack = offset > threshold || velocity > pageWidth

        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if shouldAdvance && currentPageIndex < pages.count - 1 {
                currentPageIndex += 1
                isAnimating = true
            } else if shouldGoBack && currentPageIndex > 0 {
                currentPageIndex -= 1
                isAnimating = true
            }
            dragOffset = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isAnimating = false
        }
    }

    // MARK: - Use This Page

    private var useThisPageButton: some View {
        Button {
            // Transition to clipping mode - placeholder for integration
            // This would navigate to the CollageCanvas with the selected page
        } label: {
            Label("Use This Page", systemImage: "scissors")
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(Capsule())
        }
        .accessibilityIdentifier("useThisPageButton")
    }

    private func loadPages() async {
        do {
            pages = try await magazineManager.fetchPages(for: magazine)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
