import Foundation
import CoreGraphics

struct SharedDetection {
    let boxes: [CGRect]
    let updatedAt: Date?

    var count: Int { boxes.count }

    static let appGroup = "group.com.example.BallAssist"

    static func read() -> SharedDetection {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: "latestBoxes"),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Double]] else {
            return SharedDetection(boxes: [], updatedAt: nil)
        }

        let boxes = raw.map {
            CGRect(
                x: $0["x"] ?? 0,
                y: $0["y"] ?? 0,
                width: $0["w"] ?? 0,
                height: $0["h"] ?? 0
            )
        }
        let timestamp = defaults.object(forKey: "latestTimestamp") as? TimeInterval
        return SharedDetection(boxes: boxes, updatedAt: timestamp.map(Date.init(timeIntervalSince1970:)))
    }
}
