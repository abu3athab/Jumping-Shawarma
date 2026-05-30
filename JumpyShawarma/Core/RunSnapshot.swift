import CoreGraphics
import Foundation

struct RunSnapshot {
    let score: Int
    let birdPosition: CGPoint
    let birdRotation: CGFloat
    let lastSpawnTime: TimeInterval
    let sceneSize: CGSize
}
