import SwiftUI

/// Horizontal scrollable decade filter.
struct DecadeFilterBar: View {
    @Binding var selected: MagazineDecade

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MagazineDecade.allCases) { decade in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selected = decade
                        }
                    } label: {
                        Text(decade.rawValue)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selected == decade ? Color.orange : Color(.systemGray6))
                            )
                            .foregroundStyle(selected == decade ? .white : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    DecadeFilterBar(selected: .constant(.any))
}
