import ReplayKit
import Vision
import CoreImage
import ImageIO

final class SampleHandler: RPBroadcastSampleHandler {
    private let ciContext = CIContext()
    private let request: VNDetectContoursRequest = {
        let request = VNDetectContoursRequest()
        request.contrastAdjustment = 1.2
        request.maximumImageDimension = 640
        request.detectsDarkOnLight = false
        return request
    }()

    private let appGroup = "group.com.example.BallAssist"
    private var frameCounter = 0

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        frameCounter = 0
    }

    override func broadcastPaused() {}

    override func broadcastResumed() {}

    override func broadcastFinished() {}

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer,
                                      with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // 降低处理频率，避免广播扩展占用过多资源。
        frameCounter += 1
        guard frameCounter % 5 == 0 else { return }

        do {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
            let candidates = (request.results ?? []).compactMap { contour -> CGRect? in
                let rect = contour.normalizedPath.boundingBox
                guard rect.width > 0.025, rect.height > 0.025,
                      rect.width < 0.45, rect.height < 0.45 else { return nil }

                let ratio = rect.width / max(rect.height, 0.0001)
                guard ratio > 0.72, ratio < 1.38 else { return nil }
                return rect
            }
            .sorted { ($0.width * $0.height) > ($1.width * $1.height) }
            .prefix(20)

            let payload: [[String: Double]] = candidates.map {
                ["x": Double($0.origin.x),
                 "y": Double($0.origin.y),
                 "w": Double($0.width),
                 "h": Double($0.height)]
            }

            guard let defaults = UserDefaults(suiteName: appGroup),
                  let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
            defaults.set(data, forKey: "latestBoxes")
            defaults.set(Date().timeIntervalSince1970, forKey: "latestTimestamp")
        } catch {
            // 单帧识别失败不终止广播；后续帧继续尝试。
        }
    }
}
