import SpriteKit

enum BirdNode {
    static let playerName = "player"
    static let hungryCustomerName = "hungryCustomer"
    private static let spriteName = "sprite"
    private static let playerSize = CGSize(width: 78, height: 78)
    private static var jumpSound: SKAction { GameAudioManager.shared.jumpAction }
    private static let flapScale = SKAction.sequence([
        SKAction.scale(to: 1.08, duration: 0.06),
        SKAction.scale(to: 1.0, duration: 0.08),
    ])

    private static let wrapTexture = SKTexture(imageNamed: "ShawarmaWrap")
    private static let customerTexture = SKTexture(imageNamed: "HungryCustomer")

    static func preloadAssets() {
        wrapTexture.preload {}
        customerTexture.preload {}
        wrapTexture.filteringMode = .linear
        customerTexture.filteringMode = .linear
    }

    static func make(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = playerName
        container.position = position
        container.zPosition = 10

        let sprite = SKSpriteNode(texture: wrapTexture, size: playerSize)
        sprite.name = spriteName
        sprite.zRotation = -0.45
        container.addChild(sprite)

        container.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 36, height: 42))
        container.physicsBody?.allowsRotation = false
        container.physicsBody?.restitution = 0
        container.physicsBody?.categoryBitMask = PhysicsCategory.bird
        container.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground | PhysicsCategory.fire
        container.physicsBody?.collisionBitMask = PhysicsCategory.ground
        container.physicsBody?.isDynamic = false

        return container
    }

    static func flap(_ bird: SKNode) {
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: GameConstants.flapImpulse))
        bird.run(jumpSound)
        bird.run(flapScale, withKey: "flapScale")
    }

    static func updateRotation(_ bird: SKNode) {
        guard let velocityY = bird.physicsBody?.velocity.dy else { return }
        let tilt = velocityY < 0 ? -0.15 : 0.2
        bird.zRotation = bird.zRotation * 0.85 + tilt * 0.15
    }

    static func resume(_ bird: SKNode, at position: CGPoint) {
        bird.removeAction(forKey: "flapScale")
        bird.removeAllActions()
        bird.physicsBody?.velocity = .zero
        bird.position = position
        bird.zRotation = 0
        bird.zPosition = 15
        bird.alpha = 1
        bird.setScale(1.0)
        restoreCollisions(bird)
        startFlying(bird)
        flap(bird)
    }

    static func reset(_ bird: SKNode, in sceneSize: CGSize) {
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = .zero
        bird.removeAction(forKey: "flapScale")
        bird.removeAllActions()
        bird.position = CGPoint(
            x: sceneSize.width * GameConstants.birdStartXRatio,
            y: sceneSize.height * GameConstants.birdStartYRatio
        )
        bird.zRotation = 0
        bird.zPosition = 10
        bird.alpha = 1
        bird.setScale(1.0)
        restoreCollisions(bird)
        resetSpriteRotation(bird)
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
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.pipe | PhysicsCategory.ground | PhysicsCategory.fire
    }

    static func restoreBossCollisions(_ bird: SKNode) {
        bird.physicsBody?.collisionBitMask = PhysicsCategory.ground
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.none
    }

    static func playVictoryExit(_ bird: SKNode, in scene: SKScene, completion: @escaping () -> Void) {
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.velocity = .zero
        bird.removeAllActions()
        bird.zPosition = 12

        let sceneSize = scene.size
        let customer = makeHungryCustomer(for: sceneSize)
        customer.alpha = 0
        scene.addChild(customer)

        let restX = customerRestX(in: sceneSize, customerWidth: customer.size.width)
        let restY = sceneSize.height * GameConstants.victoryCustomerCenterYRatio
        let mouthPoint = CGPoint(
            x: restX - customer.size.width * GameConstants.victoryMouthOffsetXRatio,
            y: restY - customer.size.height * GameConstants.victoryMouthOffsetYRatio
        )
        let enterDuration = GameConstants.victoryCustomerEnterDuration
        let flyDuration = GameConstants.victoryRunDuration
        let swallowDuration = GameConstants.victorySwallowDuration

        customer.run(.group([
            SKAction.move(to: CGPoint(x: restX, y: restY), duration: enterDuration),
            SKAction.fadeIn(withDuration: enterDuration * 0.75),
        ]))

        let approach = SKAction.group([
            SKAction.move(to: mouthPoint, duration: flyDuration),
            SKAction.rotate(toAngle: 0.05, duration: flyDuration * 0.65, shortestUnitArc: true),
            SKAction.scale(to: 0.92, duration: flyDuration * 0.55),
        ])
        approach.timingMode = .easeIn

        let swallow = SKAction.group([
            SKAction.move(by: CGVector(dx: 22, dy: -8), duration: swallowDuration),
            SKAction.scale(to: 0.04, duration: swallowDuration),
            SKAction.fadeOut(withDuration: swallowDuration),
        ])
        swallow.timingMode = .easeIn

        customer.run(.sequence([
            SKAction.wait(forDuration: enterDuration * 0.35 + flyDuration * 0.72),
            SKAction.sequence([
                SKAction.scaleY(to: 0.94, duration: swallowDuration * 0.35),
                SKAction.scaleY(to: 1.0, duration: swallowDuration * 0.65),
            ]),
        ]))

        bird.run(.sequence([
            SKAction.wait(forDuration: enterDuration * 0.35),
            approach,
            swallow,
            SKAction.run(completion),
        ]))
    }

    static func removeHungryCustomer(from scene: SKScene) {
        scene.childNode(withName: hungryCustomerName)?.removeFromParent()
    }

    private static func makeHungryCustomer(for sceneSize: CGSize) -> SKSpriteNode {
        let customerHeight = sceneSize.height * GameConstants.victoryCustomerHeightRatio
        let aspect = customerTexture.size().width / customerTexture.size().height
        let customerSize = CGSize(width: customerHeight * aspect, height: customerHeight)

        let customer = SKSpriteNode(texture: customerTexture, size: customerSize)
        customer.name = hungryCustomerName
        customer.zPosition = 9
        customer.position = CGPoint(
            x: sceneSize.width + customerSize.width * 0.52,
            y: sceneSize.height * GameConstants.victoryCustomerCenterYRatio
        )
        return customer
    }

    private static func customerRestX(in sceneSize: CGSize, customerWidth: CGFloat) -> CGFloat {
        sceneSize.width - customerWidth * GameConstants.victoryCustomerInsetRatio
    }

    private static func resetSpriteRotation(_ bird: SKNode) {
        bird.childNode(withName: spriteName)?.zRotation = -0.45
    }
}
