import SpriteKit

final class BossFightController {
    static let bossName = "boss1"
    static let playerFireName = "playerFire"

    private weak var scene: SKScene?
    private let theme: ThemePalette
    private var boss: SKSpriteNode!
    private var hitsRemaining: Int
    private var lastBossShotTime: TimeInterval = 0
    private var canPlayerShoot = true
    private var isPaused = true
    private let onHealthChanged: (Int) -> Void
    private let onDefeated: () -> Void

    private static let boss1Texture: SKTexture = {
        let texture = SKTexture(imageNamed: "Boss1")
        texture.preload {}
        texture.filteringMode = .linear
        return texture
    }()

    init(
        theme: ThemePalette,
        hitsRemaining: Int = GameConstants.bossHitsToDefeat,
        onHealthChanged: @escaping (Int) -> Void,
        onDefeated: @escaping () -> Void
    ) {
        self.theme = theme
        self.hitsRemaining = hitsRemaining
        self.onHealthChanged = onHealthChanged
        self.onDefeated = onDefeated
    }

    var currentHitsRemaining: Int { hitsRemaining }

    func start(in scene: SKScene) {
        self.scene = scene
        lastBossShotTime = 0
        canPlayerShoot = true
        onHealthChanged(healthPercent)

        let sceneSize = scene.size
        let bossHeight = sceneSize.height * GameConstants.boss1HeightRatio
        let aspect = Self.boss1Texture.size().width / Self.boss1Texture.size().height
        let bossSize = CGSize(width: bossHeight * aspect, height: bossHeight)

        boss = SKSpriteNode(texture: Self.boss1Texture, size: bossSize)
        boss.name = Self.bossName
        boss.zPosition = 9
        boss.position = CGPoint(
            x: sceneSize.width - bossSize.width * GameConstants.boss1InsetRatio,
            y: sceneSize.height * GameConstants.boss1CenterYRatio
        )

        let body = SKPhysicsBody(rectangleOf: CGSize(width: bossSize.width * 0.50, height: bossSize.height * 0.62))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.boss
        body.contactTestBitMask = PhysicsCategory.playerFire
        body.collisionBitMask = PhysicsCategory.none
        boss.physicsBody = body

        boss.alpha = hitsRemaining == GameConstants.bossHitsToDefeat ? 0 : 1
        scene.addChild(boss)
        if boss.alpha == 0 {
            boss.run(.fadeIn(withDuration: 0.45))
        }

        startBossShooting()
    }

    func setPaused(_ paused: Bool) {
        isPaused = paused
        if paused {
            lastBossShotTime = 0
        }
    }

    func cleanup() {
        boss?.removeAllActions()
        boss?.removeFromParent()
        boss = nil
        scene?.enumerateChildNodes(withName: FireHazard.fireballName) { node, _ in
            node.removeFromParent()
        }
        scene?.enumerateChildNodes(withName: Self.playerFireName) { node, _ in
            node.removeFromParent()
        }
        scene = nil
    }

    func update(currentTime: TimeInterval, bird: SKNode) -> ContactResult? {
        guard boss?.parent != nil else { return nil }
        if let result = checkCollisions(with: bird) {
            return result
        }
        guard !isPaused else { return nil }
        guard currentTime - lastBossShotTime >= GameConstants.bossFireInterval else { return nil }
        shootBossBurst(at: bird)
        lastBossShotTime = currentTime
        return nil
    }

    func shootPlayerFire(from bird: SKNode) {
        guard !isPaused, canPlayerShoot, hitsRemaining > 0, let scene else { return }
        canPlayerShoot = false

        scene.run(.sequence([
            .wait(forDuration: GameConstants.bossPlayerFireCooldown),
            .run { [weak self] in self?.canPlayerShoot = true },
        ]))

        let origin = CGPoint(x: bird.position.x + 28, y: bird.position.y)
        spawnFireball(
            named: Self.playerFireName,
            at: origin,
            in: scene,
            velocity: CGVector(dx: GameConstants.bossPlayerFireSpeed, dy: 0),
            category: PhysicsCategory.playerFire,
            contactMask: PhysicsCategory.boss
        )
    }

    enum ContactResult {
        case playerHit
        case bossDamaged
    }

    private func checkCollisions(with bird: SKNode) -> ContactResult? {
        guard let boss else { return nil }

        let bossHitbox = boss.frame.insetBy(
            dx: boss.size.width * 0.22,
            dy: boss.size.height * 0.16
        )

        scene?.enumerateChildNodes(withName: Self.playerFireName) { node, _ in
            if bossHitbox.intersects(node.calculateAccumulatedFrame()) {
                node.removeFromParent()
                self.applyBossDamage()
            }
        }

        let hitDistance = GameConstants.bossFireHitRadius + GameConstants.birdHitRadius
        let hitDistanceSquared = hitDistance * hitDistance

        var playerHit = false
        scene?.enumerateChildNodes(withName: FireHazard.fireballName) { node, stop in
            let dx = node.position.x - bird.position.x
            let dy = node.position.y - bird.position.y
            if (dx * dx + dy * dy) <= hitDistanceSquared {
                playerHit = true
                stop.pointee = true
            }
        }

        return playerHit ? .playerHit : nil
    }

    private var healthPercent: Int {
        max(0, hitsRemaining * GameConstants.bossDamagePercent)
    }

    private func applyBossDamage() {
        guard hitsRemaining > 0 else { return }
        hitsRemaining -= 1
        onHealthChanged(healthPercent)

        boss.run(.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.55, duration: 0.05),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.12),
        ]))

        if hitsRemaining <= 0 {
            defeatBoss()
        }
    }

    private func defeatBoss() {
        guard let boss, boss.parent != nil else { return }
        boss.removeAllActions()
        boss.run(.sequence([
            .group([
                .fadeOut(withDuration: 0.35),
                .scale(to: 0.85, duration: 0.35),
            ]),
            .run { [weak self] in
                self?.boss?.removeFromParent()
                self?.onDefeated()
            },
        ]))
    }

    private func startBossShooting() {
        boss.run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 8, duration: 0.9),
            .moveBy(x: 0, y: -8, duration: 0.9),
        ])), withKey: "bob")
    }

    private func shootBossBurst(at bird: SKNode) {
        guard let scene, let boss else { return }

        let mouth = CGPoint(
            x: boss.position.x - boss.size.width * GameConstants.boss1MouthOffsetXRatio,
            y: boss.position.y - boss.size.height * GameConstants.boss1MouthOffsetYRatio
        )

        let dx = bird.position.x - mouth.x
        let dy = bird.position.y - mouth.y
        let baseAngle = atan2(dy, dx)
        let speed = GameConstants.bossEnemyFireSpeed

        let shotCount = Int.random(in: 1...2)
        for _ in 0..<shotCount {
            let spread = CGFloat.random(in: -0.1 ... 0.1)
            let angle = baseAngle + spread
            let velocity = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
            spawnFireball(
                named: FireHazard.fireballName,
                at: mouth,
                in: scene,
                velocity: velocity,
                category: PhysicsCategory.fire,
                contactMask: PhysicsCategory.bird
            )
        }
    }

    private func spawnFireball(
        named name: String,
        at position: CGPoint,
        in scene: SKScene,
        velocity: CGVector,
        category: UInt32,
        contactMask: UInt32
    ) {
        let ball = SKShapeNode(ellipseOf: CGSize(width: 20, height: 14))
        ball.fillColor = theme.accentSecondary
        ball.strokeColor = theme.accent
        ball.lineWidth = 2
        ball.name = name
        ball.position = position
        ball.zPosition = 8

        let core = SKShapeNode(ellipseOf: CGSize(width: 9, height: 6))
        core.fillColor = theme.accentGlow
        core.strokeColor = .clear
        core.zPosition = 1
        ball.addChild(core)

        let body = SKPhysicsBody(circleOfRadius: 9)
        body.isDynamic = false
        body.usesPreciseCollisionDetection = true
        body.categoryBitMask = category
        body.contactTestBitMask = contactMask
        body.collisionBitMask = PhysicsCategory.none
        ball.physicsBody = body

        scene.addChild(ball)

        let speed = hypot(velocity.dx, velocity.dy)
        let travel = max(scene.size.width, scene.size.height) * 1.1
        let duration = TimeInterval(travel / speed)
        let unitX = velocity.dx / speed
        let unitY = velocity.dy / speed

        ball.run(.sequence([
            .moveBy(x: unitX * travel, y: unitY * travel, duration: duration),
            .removeFromParent(),
        ]))
    }
}
