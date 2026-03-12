import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \CollageProject.modifiedAt, order: .reverse)
    private var projects: [CollageProject]

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 24) {
                        // New Collage button
                        NewCollageButton()
                            .padding(.horizontal)

                        // Recent projects
                        if !projects.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Projects")
                                    .font(.headline)
                                    .padding(.horizontal)

                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(projects) { project in
                                        ProjectCardView(project: project)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Starter templates
                        TemplateRowView()

                        // Inspiration gallery
                        InspirationGalleryView()

                        // Bottom spacing for ingredients tray
                        Spacer()
                            .frame(height: 80)
                    }
                    .padding(.top)
                }

                // Persistent bottom drawer
                IngredientsTrayView()
            }
            .navigationTitle("Snippit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SavesRemainingView()
                }
            }
        }
        .accessibilityIdentifier("homeTab")
    }
}

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}

#if DEBUG
@MainActor
let previewContainer: ModelContainer = {
    let container = try! ModelContainer(
        for: CollageProject.self, ClippedItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    for project in CollageProject.previewList {
        container.mainContext.insert(project)
    }
    return container
}()
#endif
