import SwiftUI

/// Horizontal scrollable category filter pills.
struct CategoryFilterBar: View {
    @Binding var selected: MagazineCategory

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MagazineCategory.allCases) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = category
                        }
                    } label: {
                        Label(category.rawValue, systemImage: category.iconName)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selected == category ? Color.accentColor : Color(.systemGray5))
                            )
                            .foregroundStyle(selected == category ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("category-\(category.rawValue)")
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CategoryFilterBar(selected: .constant(.all))
}
