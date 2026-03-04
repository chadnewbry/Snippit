import SwiftUI

struct InspirationGalleryView: View {
    @State private var showingStaffPicksOnly = false

    private var items: [InspirationItem] {
        showingStaffPicksOnly
            ? InspirationItem.sampleGallery.filter(\.isStaffPick)
            : InspirationItem.sampleGallery
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Inspiration")
                    .font(.headline)
                Spacer()
                Button(showingStaffPicksOnly ? "All" : "Staff Picks") {
                    withAnimation { showingStaffPicksOnly.toggle() }
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.purple)
            }
            .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    InspirationCard(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct InspirationCard: View {
    let item: InspirationItem

    private var color: Color {
        switch item.placeholderColor {
        case "orange": .orange
        case "brown": .brown
        case "green": .green
        case "blue": .blue
        case "pink": .pink
        case "gray": .gray
        default: .purple
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.gradient.opacity(0.4))
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    if item.isStaffPick {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                            .padding(6)
                    }
                }

            Text(item.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text("by \(item.author)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
