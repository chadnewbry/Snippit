import CoreGraphics
import CoreImage
import Vision

/// Uses Vision framework for smart subject selection and segmentation.
@Observable
final class AIClippingEngine {
    private(set) var isProcessing = false

    /// Performs subject lifting (iOS 17+ VNGenerateForegroundInstanceMaskRequest).
    func extractSubject(from image: CGImage) async throws -> CGImage {
        isProcessing = true
        defer { isProcessing = false }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let result = request.results?.first else {
            throw ClippingError.noSubjectFound
        }

        let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
        return try applyMask(mask, to: image)
    }

    /// Detects salient regions in the image for auto-crop suggestions.
    func detectSalientRegions(in image: CGImage) async throws -> [CGRect] {
        let request = VNGenerateAttentionBasedSaliencyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let result = request.results?.first else { return [] }
        return result.salientObjects?.map { $0.boundingBox } ?? []
    }

    /// Detects text regions to avoid or include in clippings.
    func detectTextRegions(in image: CGImage) async throws -> [CGRect] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        return request.results?.map { $0.boundingBox } ?? []
    }

    // MARK: - Private

    private func applyMask(_ mask: CVPixelBuffer, to image: CGImage) throws -> CGImage {
        let ciMask = CIImage(cvPixelBuffer: mask)
        let ciImage = CIImage(cgImage: image)

        let context = CIContext()

        guard let filter = CIFilter(name: "CIBlendWithMask") else {
            throw ClippingError.maskApplicationFailed
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(ciMask, forKey: kCIInputMaskImageKey)
        filter.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)

        guard let output = filter.outputImage,
              let cgResult = context.createCGImage(output, from: ciImage.extent) else {
            throw ClippingError.maskApplicationFailed
        }
        return cgResult
    }
}

enum ClippingError: LocalizedError {
    case noSubjectFound
    case maskApplicationFailed

    var errorDescription: String? {
        switch self {
        case .noSubjectFound: "No subject found in the image."
        case .maskApplicationFailed: "Failed to apply the clipping mask."
        }
    }
}
