import SwiftUI

struct TemplateRowView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start Fresh")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(StarterTemplate.all) { template in
                        TemplateCard(template: template)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct TemplateCard: View {
    let template: StarterTemplate

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: template.icon)
                .font(.title)
                .frame(width: 56, height: 56)
                .background(.purple.opacity(0.15), in: Circle())
                .foregroundStyle(.purple)

            Text(template.name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)

            Text(template.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 110)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityIdentifier("template-\(template.name)")
    }
}
