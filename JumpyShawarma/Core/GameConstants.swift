import CoreGraphics
import Foundation
import UIKit

enum GameConstants {
    static let gravity: CGFloat = -9.0
    static let flapImpulse: CGFloat = 30

    static let pipeSpawnInterval: TimeInterval = 1.45
    static let iPadPipeSpawnInterval: TimeInterval = 1.8
    static let pipeSpeed: CGFloat = 180
    static let pipeWidth: CGFloat = 58
    static let pipePhysicsWidthRatio: CGFloat = 0.84
    static let pipePhysicsGapInsetPhone: CGFloat = 6
    static let pipePhysicsGapInsetPad: CGFloat = 14

    static var pipePhysicsGapInset: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? pipePhysicsGapInsetPad : pipePhysicsGapInsetPhone
    }

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

    static let fireballSpeed: CGFloat = 175
    static let fireballTravelDistance: CGFloat = 300

    static let bossHitsToDefeat = 10
    static let bossDamagePercent = 10
    static let bossFireInterval: TimeInterval = 0.85
    static let bossPlayerFireCooldown: TimeInterval = 0.28
    static let bossPlayerFireSpeed: CGFloat = 440
    static let bossEnemyFireSpeed: CGFloat = 250
    static let boss1HeightRatio: CGFloat = 0.34
    static let boss1CenterYRatio: CGFloat = 0.52
    static let boss1InsetRatio: CGFloat = 0.10
    static let boss1MouthOffsetXRatio: CGFloat = 0.40
    static let boss1MouthOffsetYRatio: CGFloat = 0.06
    static let bossFireHitRadius: CGFloat = 11
    static let birdHitRadius: CGFloat = 18

    static var pipeSpawnIntervalForDevice: TimeInterval {
        UIDevice.current.userInterfaceIdiom == .pad ? iPadPipeSpawnInterval : pipeSpawnInterval
    }
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
