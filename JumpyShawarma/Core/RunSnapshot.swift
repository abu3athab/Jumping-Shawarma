import CoreGraphics
import Foundation

struct RunSnapshot {
    struct BossFightResumeState {
        let hitsRemaining: Int
        let lockedX: CGFloat
    }

    let score: Int
    let birdPosition: CGPoint
    let birdRotation: CGFloat
    let lastSpawnTime: TimeInterval
    let sceneSize: CGSize
    let bossFightResume: BossFightResumeState?
}
