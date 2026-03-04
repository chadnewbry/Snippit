import CoreGraphics
import PhotosUI
import SwiftUI
import UIKit

/// Manages state for the Smart Clipping & Selection workflow.
@Observable
final class SmartClippingViewModel {
    // MARK: - Source

    private(set) var sourceImage: UIImage?
    private(set) var sourceCGImage: CGImage?

    // MARK: - Tool State

    enum ClippingTool: String, CaseIterable, Identifiable {
        case tapSelect = "Tap Select"
        case lasso = "Lasso"
        case refine = "Refine"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .tapSelect: "hand.tap"
            case .lasso: "lasso"
            case .refine: "paintbrush.pointed"
            }
        }
    }

    var activeTool: ClippingTool = .tapSelect
    var isProcessing = false

    // MARK: - Selections

    /// Each clipped region stores its mask image and bounding box.
    struct ClippedRegion: Identifiable {
        let id = UUID()
        var maskImage: CGImage
        var boundingBox: CGRect
        var extractedImage: CGImage
        var useRippedEdge = true
    }

    var clippedRegions: [ClippedRegion] = []

    // MARK: - Lasso

    var lassoPoints: [CGPoint] = []
    var isDrawingLasso = false

    // MARK: - Refine

    enum RefineMode { case add, subtract }
    var refineMode: RefineMode = .add
    var refineBrushSize: CGFloat = 20

    // MARK: - Confirmation

    var showClipConfirmation = false

    // MARK: - AI Engine

    private let clippingEngine = AIClippingEngine()

    // MARK: - Actions

    func setSourceImage(_ image: UIImage) {
        sourceImage = image
        sourceCGImage = image.cgImage
    }

    func loadPhotos(_ items: [PhotosPickerItem]) async {
        guard let first = items.first,
              let data = try? await first.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await MainActor.run {
            setSourceImage(image)
        }
    }

    func reset() {
        sourceImage = nil
        sourceCGImage = nil
        clippedRegions = []
        lassoPoints = []
        isDrawingLasso = false
        activeTool = .tapSelect
    }

    // MARK: - Tap to Select (AI Subject Extraction)

    func tapToSelect(at normalizedPoint: CGPoint) async {
        guard let cgImage = sourceCGImage else { return }
        isProcessing = true
        defer { isProcessing = false }

        do {
            let extracted = try await clippingEngine.extractSubject(from: cgImage)
            let region = ClippedRegion(
                maskImage: extracted,
                boundingBox: CGRect(origin: .zero, size: CGSize(width: cgImage.width, height: cgImage.height)),
                extractedImage: extracted
            )
            clippedRegions.append(region)
        } catch {
            print("Tap-to-select failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Lasso Selection

    func completeLasso() async {
        guard let cgImage = sourceCGImage, lassoPoints.count >= 3 else {
            lassoPoints = []
            isDrawingLasso = false
            return
        }
        isProcessing = true
        defer {
            isProcessing = false
            lassoPoints = []
            isDrawingLasso = false
        }

        // Create mask from lasso path, then use AI to snap to edges
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        let mask = createLassoMask(points: lassoPoints, imageSize: imageSize)

        if let masked = applyPathMask(mask, to: cgImage, imageSize: imageSize) {
            // Try AI refinement on the rough selection
            do {
                let refined = try await clippingEngine.extractSubject(from: masked)
                let region = ClippedRegion(
                    maskImage: refined,
                    boundingBox: boundingBoxForPoints(lassoPoints, imageSize: imageSize),
                    extractedImage: refined
                )
                clippedRegions.append(region)
            } catch {
                // Fall back to raw lasso cut
                let region = ClippedRegion(
                    maskImage: masked,
                    boundingBox: boundingBoxForPoints(lassoPoints, imageSize: imageSize),
                    extractedImage: masked
                )
                clippedRegions.append(region)
            }
        }
    }

    // MARK: - Batch / Multi-Select

    func autoDetectAllElements() async {
        guard let cgImage = sourceCGImage else { return }
        isProcessing = true
        defer { isProcessing = false }

        do {
            let salient = try await clippingEngine.detectSalientRegions(in: cgImage)
            let textRegions = try await clippingEngine.detectTextRegions(in: cgImage)
            let allRegions = salient + textRegions

            for box in allRegions {
                let pixelRect = CGRect(
                    x: box.origin.x * CGFloat(cgImage.width),
                    y: (1 - box.origin.y - box.height) * CGFloat(cgImage.height),
                    width: box.width * CGFloat(cgImage.width),
                    height: box.height * CGFloat(cgImage.height)
                )

                if let cropped = cgImage.cropping(to: pixelRect) {
                    let region = ClippedRegion(
                        maskImage: cropped,
                        boundingBox: pixelRect,
                        extractedImage: cropped
                    )
                    clippedRegions.append(region)
                }
            }
        } catch {
            print("Auto-detect failed: \(error.localizedDescription)")
        }
    }

    func removeRegion(_ region: ClippedRegion) {
        clippedRegions.removeAll { $0.id == region.id }
    }

    func toggleRippedEdge(for regionID: UUID) {
        guard let idx = clippedRegions.firstIndex(where: { $0.id == regionID }) else { return }
        clippedRegions[idx].useRippedEdge.toggle()
    }

    // MARK: - Export

    func exportClippedItems() -> [ClippedItem] {
        clippedRegions.map { region in
            let image = UIImage(cgImage: region.extractedImage)
            let data = image.pngData() ?? Data()
            return ClippedItem(imageData: data)
        }
    }

    // MARK: - Private Helpers

    private func createLassoMask(points: [CGPoint], imageSize: CGSize) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        path.move(to: CGPoint(x: first.x * imageSize.width, y: first.y * imageSize.height))
        for pt in points.dropFirst() {
            path.addLine(to: CGPoint(x: pt.x * imageSize.width, y: pt.y * imageSize.height))
        }
        path.closeSubpath()
        return path
    }

    private func applyPathMask(_ path: CGPath, to image: CGImage, imageSize: CGSize) -> CGImage? {
        let width = image.width
        let height = image.height
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.addPath(path)
        context.clip()
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }

    private func boundingBoxForPoints(_ points: [CGPoint], imageSize: CGSize) -> CGRect {
        let xs = points.map { $0.x * imageSize.width }
        let ys = points.map { $0.y * imageSize.height }
        let minX = xs.min() ?? 0
        let minY = ys.min() ?? 0
        let maxX = xs.max() ?? 0
        let maxY = ys.max() ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}
