import Foundation

struct InspirationItem: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let isStaffPick: Bool
    let placeholderColor: String

    static let sampleGallery: [InspirationItem] = [
        InspirationItem(title: "Sunset Layers", author: "emma_creates", isStaffPick: true, placeholderColor: "orange"),
        InspirationItem(title: "Vintage Typography", author: "retro.joe", isStaffPick: true, placeholderColor: "brown"),
        InspirationItem(title: "Botanical Dreams", author: "leaf.studio", isStaffPick: false, placeholderColor: "green"),
        InspirationItem(title: "City Pulse", author: "urban_art", isStaffPick: false, placeholderColor: "blue"),
        InspirationItem(title: "Pastel Memories", author: "soft.collage", isStaffPick: true, placeholderColor: "pink"),
        InspirationItem(title: "Dark Aesthetic", author: "noir.design", isStaffPick: false, placeholderColor: "gray"),
    ]
}

#if DEBUG
extension InspirationItem: PreviewData {
    static var preview: InspirationItem { InspirationItem.sampleGallery[0] }
    static var previewList: [InspirationItem] { InspirationItem.sampleGallery }
}
#endif
