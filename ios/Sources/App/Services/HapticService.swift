import UIKit

@MainActor
enum HapticService {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func impactMedium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func impactLight() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
