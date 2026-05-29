import SpriteKit

enum BirdNode {
    private static let spriteName = "sprite"
    private static let playerSize = CGSize(width: 80, height: 58)

    static func make(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = 10

        let texture = SKTexture(imageNamed: "ShawarmaPlayer")
        let sprite = SKSpriteNode(texture: texture, size: playerSize)
        sprite.name = spriteName
        container.addChild(sprite)

        container.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 34, height: 46))
        container.physicsBody?.allowsRotation = false
        container.physicsBody?.categoryBitMask = PhysicsCategory.bird
        container.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground
        container.physicsBody?.collisionBitMask = PhysicsCategory.pipe | PhysicsCategory.ground
        container.physicsBody?.isDynamic = false

        return container
    }

    static func flap(_ bird: SKNode) {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConstants.flapImpulse))

        bird.run(.sequence([
            .scale(to: 1.08, duration: 0.06),
            .scale(to: 1.0, duration: 0.08),
        ]))
    }

    static func updateRotation(_ bird: SKNode) {
        guard let velocityY = bird.physicsBody?.velocity.dy else { return }
        let tilt = velocityY < 0 ? -0.15 : 0.2
        bird.zRotation = bird.zRotation * 0.85 + tilt * 0.15
    }

    static func reset(_ bird: SKNode, in sceneSize: CGSize) {
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = .zero
        bird.position = CGPoint(
            x: sceneSize.width * GameConstants.birdStartXRatio,
            y: sceneSize.height * GameConstants.birdStartYRatio
        )
        bird.zRotation = 0
        bird.setScale(1.0)
    }

    static func startFlying(_ bird: SKNode) {
        bird.physicsBody?.isDynamic = true
    }

    static func stop(_ bird: SKNode) {
        bird.physicsBody?.isDynamic = false
    }
}
