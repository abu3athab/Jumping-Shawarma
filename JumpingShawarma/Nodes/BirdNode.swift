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
        bird.removeAllActions()
        bird.position = CGPoint(
            x: sceneSize.width * GameConstants.birdStartXRatio,
            y: sceneSize.height * GameConstants.birdStartYRatio
        )
        bird.zRotation = 0
        bird.setScale(1.0)
        restoreCollisions(bird)
    }

    static func startFlying(_ bird: SKNode) {
        bird.physicsBody?.isDynamic = true
    }

    static func stop(_ bird: SKNode) {
        bird.physicsBody?.isDynamic = false
    }

    static func disableCollisions(_ bird: SKNode) {
        bird.physicsBody?.collisionBitMask = PhysicsCategory.none
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.none
    }

    static func restoreCollisions(_ bird: SKNode) {
        bird.physicsBody?.collisionBitMask = PhysicsCategory.pipe | PhysicsCategory.ground
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground
    }

    static func playVictoryExit(_ bird: SKNode, in sceneSize: CGSize, completion: @escaping () -> Void) {
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = .zero
        bird.removeAllActions()

        let targetX = sceneSize.width + GameConstants.victoryExitBeyondScreen
        let targetY = min(
            bird.position.y + 24,
            sceneSize.height * 0.58
        )
        let duration = GameConstants.victoryRunDuration

        let move = SKAction.group([
            SKAction.moveTo(x: targetX, duration: duration),
            SKAction.moveTo(y: targetY, duration: duration * 0.7),
        ])
        move.timingMode = .easeIn

        let flip = SKAction.repeat(
            SKAction.sequence([
                SKAction.rotate(byAngle: .pi * 2, duration: duration / 3.5),
            ]),
            count: 2
        )

        let celebrate = SKAction.group([
            move,
            flip,
            SKAction.sequence([
                SKAction.scale(to: 1.12, duration: duration * 0.35),
                SKAction.scale(to: 1.0, duration: duration * 0.35),
            ]),
        ])

        bird.run(.sequence([
            celebrate,
            SKAction.run(completion),
        ]))
    }
}
