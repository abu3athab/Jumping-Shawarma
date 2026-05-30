import CoreGraphics
import Foundation

enum GameConstants {
    static let gravity: CGFloat = -9.0
    static let flapImpulse: CGFloat = 30

    static let pipeSpawnInterval: TimeInterval = 1.45
    static let pipeSpeed: CGFloat = 180
    static let pipeWidth: CGFloat = 58
    static let gapHeight: CGFloat = 158

    static let birdStartXRatio: CGFloat = 0.32
    static let birdStartYRatio: CGFloat = 0.55
    static let groundHeight: CGFloat = 72

    static let maxBirdRotation: CGFloat = 0.9
    static let minBirdRotation: CGFloat = -0.45

    static let bestScoreKey = "jumpy_shawarma_best"

    static let victoryRunDuration: TimeInterval = 1.35
    static let victorySwallowDuration: TimeInterval = 0.32
    static let victoryCustomerEnterDuration: TimeInterval = 0.55
    static let victoryExitBeyondScreen: CGFloat = 60
    static let victoryCustomerHeightRatio: CGFloat = 0.58
    static let victoryCustomerCenterYRatio: CGFloat = 0.50
    static let victoryCustomerInsetRatio: CGFloat = 0.16
    static let victoryMouthOffsetXRatio: CGFloat = 0.30
    static let victoryMouthOffsetYRatio: CGFloat = 0.035
    static let obstacleExitDuration: TimeInterval = 0.55
    static let continueInvincibilityDuration: TimeInterval = 0.8
    static let continueCountdownStepDuration: TimeInterval = 1.0
    static let continueSpawnClearance: CGFloat = 140
}

enum GameHUDLayout {
    static let scoreBadgeSize = CGSize(width: 136, height: 84)
    static let hudTopInset: CGFloat = 8
    static let captionOffsetFromBadgeCenter: CGFloat = 18
    static let scoreOffsetFromBadgeCenter: CGFloat = 20

    /// SwiftUI padding and SpriteKit HUD share this top inset below the safe area.
    static func hudTopPadding(safeAreaTop: CGFloat) -> CGFloat {
        safeAreaTop + hudTopInset
    }

    static func badgeCenterY(sceneHeight: CGFloat, safeAreaTop: CGFloat) -> CGFloat {
        let badgeTop = hudTopPadding(safeAreaTop: safeAreaTop)
        return sceneHeight - badgeTop - scoreBadgeSize.height / 2
    }
}
