import Foundation
import UIKit

/// Curated font library organized by mood categories.
struct FontLibrary {
    
    enum Mood: String, CaseIterable, Identifiable {
        case handwritten = "Handwritten"
        case vintageSerif = "Vintage Serif"
        case typewriter = "Typewriter"
        case magazineHeadline = "Magazine Headline"
        case modern = "Modern"
        case playful = "Playful"
        case elegant = "Elegant"
        case bold = "Bold & Impact"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .handwritten: return "pencil.and.scribble"
            case .vintageSerif: return "textformat"
            case .typewriter: return "keyboard"
            case .magazineHeadline: return "newspaper"
            case .modern: return "textformat.abc"
            case .playful: return "sparkles"
            case .elegant: return "crown"
            case .bold: return "bold"
            }
        }
    }
    
    struct FontEntry: Identifiable {
        let id = UUID()
        let name: String        // PostScript/system font name
        let displayName: String // Human-readable name
        let mood: Mood
        
        /// Whether this font is available on the current device
        var isAvailable: Bool {
            UIFont(name: name, size: 12) != nil
        }
    }
    
    /// All curated fonts (50+ entries using iOS system fonts)
    static let allFonts: [FontEntry] = [
        // Handwritten (8)
        FontEntry(name: "BradleyHandITCTT-Bold", displayName: "Bradley Hand", mood: .handwritten),
        FontEntry(name: "SnellRoundhand", displayName: "Snell Roundhand", mood: .handwritten),
        FontEntry(name: "SnellRoundhand-Bold", displayName: "Snell Roundhand Bold", mood: .handwritten),
        FontEntry(name: "SnellRoundhand-Black", displayName: "Snell Roundhand Black", mood: .handwritten),
        FontEntry(name: "MarkerFelt-Thin", displayName: "Marker Felt Thin", mood: .handwritten),
        FontEntry(name: "MarkerFelt-Wide", displayName: "Marker Felt Wide", mood: .handwritten),
        FontEntry(name: "Chalkduster", displayName: "Chalkduster", mood: .handwritten),
        FontEntry(name: "SavoyeLetPlain", displayName: "Savoye Let", mood: .handwritten),
        
        // Vintage Serif (8)
        FontEntry(name: "Baskerville", displayName: "Baskerville", mood: .vintageSerif),
        FontEntry(name: "Baskerville-Bold", displayName: "Baskerville Bold", mood: .vintageSerif),
        FontEntry(name: "Baskerville-Italic", displayName: "Baskerville Italic", mood: .vintageSerif),
        FontEntry(name: "Georgia", displayName: "Georgia", mood: .vintageSerif),
        FontEntry(name: "Georgia-Bold", displayName: "Georgia Bold", mood: .vintageSerif),
        FontEntry(name: "Palatino-Roman", displayName: "Palatino", mood: .vintageSerif),
        FontEntry(name: "Palatino-Bold", displayName: "Palatino Bold", mood: .vintageSerif),
        FontEntry(name: "TimesNewRomanPSMT", displayName: "Times New Roman", mood: .vintageSerif),
        
        // Typewriter (6)
        FontEntry(name: "Courier", displayName: "Courier", mood: .typewriter),
        FontEntry(name: "Courier-Bold", displayName: "Courier Bold", mood: .typewriter),
        FontEntry(name: "CourierNewPSMT", displayName: "Courier New", mood: .typewriter),
        FontEntry(name: "CourierNewPS-BoldMT", displayName: "Courier New Bold", mood: .typewriter),
        FontEntry(name: "AmericanTypewriter", displayName: "American Typewriter", mood: .typewriter),
        FontEntry(name: "AmericanTypewriter-Bold", displayName: "American Typewriter Bold", mood: .typewriter),
        
        // Magazine Headline (7)
        FontEntry(name: "Futura-Bold", displayName: "Futura Bold", mood: .magazineHeadline),
        FontEntry(name: "Futura-CondensedExtraBold", displayName: "Futura Condensed", mood: .magazineHeadline),
        FontEntry(name: "Futura-Medium", displayName: "Futura Medium", mood: .magazineHeadline),
        FontEntry(name: "DINCondensed-Bold", displayName: "DIN Condensed", mood: .magazineHeadline),
        FontEntry(name: "DINAlternate-Bold", displayName: "DIN Alternate", mood: .magazineHeadline),
        FontEntry(name: "GillSans-Bold", displayName: "Gill Sans Bold", mood: .magazineHeadline),
        FontEntry(name: "GillSans-UltraBold", displayName: "Gill Sans Ultra Bold", mood: .magazineHeadline),
        
        // Modern (7)
        FontEntry(name: "HelveticaNeue", displayName: "Helvetica Neue", mood: .modern),
        FontEntry(name: "HelveticaNeue-Light", displayName: "Helvetica Neue Light", mood: .modern),
        FontEntry(name: "HelveticaNeue-Thin", displayName: "Helvetica Neue Thin", mood: .modern),
        FontEntry(name: "HelveticaNeue-UltraLight", displayName: "Helvetica Neue UltraLight", mood: .modern),
        FontEntry(name: "AvenirNext-Regular", displayName: "Avenir Next", mood: .modern),
        FontEntry(name: "AvenirNext-Medium", displayName: "Avenir Next Medium", mood: .modern),
        FontEntry(name: "AvenirNext-DemiBold", displayName: "Avenir Next DemiBold", mood: .modern),
        
        // Playful (7)
        FontEntry(name: "Papyrus", displayName: "Papyrus", mood: .playful),
        FontEntry(name: "PartyLetPlain", displayName: "Party Let", mood: .playful),
        FontEntry(name: "Chalkboard-Bold", displayName: "Chalkboard Bold", mood: .playful),
        FontEntry(name: "ChalkboardSE-Bold", displayName: "Chalkboard SE Bold", mood: .playful),
        FontEntry(name: "ChalkboardSE-Regular", displayName: "Chalkboard SE", mood: .playful),
        FontEntry(name: "TrebuchetMS", displayName: "Trebuchet MS", mood: .playful),
        FontEntry(name: "TrebuchetMS-Bold", displayName: "Trebuchet MS Bold", mood: .playful),
        
        // Elegant (7)
        FontEntry(name: "Didot", displayName: "Didot", mood: .elegant),
        FontEntry(name: "Didot-Bold", displayName: "Didot Bold", mood: .elegant),
        FontEntry(name: "Didot-Italic", displayName: "Didot Italic", mood: .elegant),
        FontEntry(name: "Copperplate", displayName: "Copperplate", mood: .elegant),
        FontEntry(name: "Copperplate-Bold", displayName: "Copperplate Bold", mood: .elegant),
        FontEntry(name: "Optima-Regular", displayName: "Optima", mood: .elegant),
        FontEntry(name: "Optima-Bold", displayName: "Optima Bold", mood: .elegant),
        
        // Bold & Impact (6)
        FontEntry(name: "Impact", displayName: "Impact", mood: .bold),
        FontEntry(name: "AvenirNext-Heavy", displayName: "Avenir Next Heavy", mood: .bold),
        FontEntry(name: "AvenirNext-Bold", displayName: "Avenir Next Bold", mood: .bold),
        FontEntry(name: "HelveticaNeue-Bold", displayName: "Helvetica Neue Bold", mood: .bold),
        FontEntry(name: "HelveticaNeue-CondensedBlack", displayName: "Helvetica Condensed Black", mood: .bold),
        FontEntry(name: "HelveticaNeue-CondensedBold", displayName: "Helvetica Condensed Bold", mood: .bold),
    ]
    
    /// Fonts filtered by mood
    static func fonts(for mood: Mood) -> [FontEntry] {
        allFonts.filter { $0.mood == mood && $0.isAvailable }
    }
    
    /// All available fonts
    static var availableFonts: [FontEntry] {
        allFonts.filter(\.isAvailable)
    }
    
    /// Random font (used by ransom note mode)
    static func randomFont() -> FontEntry {
        availableFonts.randomElement() ?? allFonts[0]
    }
}
