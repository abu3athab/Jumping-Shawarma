import SpriteKit

enum FireHazard {
    static let shooterName = "fireShooter"
    static let fireballName = "fireball"

    static func attachShootersIfNeeded(
        to topPipe: SKSpriteNode,
        bottomPipe: SKSpriteNode,
        theme: ThemePalette,
        enabled: Bool
    ) {
        guard enabled else { return }
        let pipe = Bool.random() ? topPipe : bottomPipe
        let isTop = pipe === topPipe
        attachShooter(to: pipe, isTop: isTop, theme: theme)
    }

    static func removeAll(from scene: SKScene) {
        scene.enumerateChildNodes(withName: fireballName) { node, _ in
            node.removeAllActions()
            node.removeFromParent()
        }
    }

    static func stopAll(in scene: SKScene) {
        scene.enumerateChildNodes(withName: fireballName) { node, _ in
            node.removeAllActions()
        }
        scene.enumerateChildNodes(withName: PipeNode.pipeName) { pipe, _ in
            pipe.enumerateChildNodes(withName: shooterName) { shooter, _ in
                shooter.removeAllActions()
            }
        }
    }

    private static func attachShooter(to pipe: SKSpriteNode, isTop: Bool, theme: ThemePalette) {
        let shooter = SKNode()
        shooter.name = shooterName
        shooter.zPosition = 4

        let mouth = makeMouth(theme: theme)
        shooter.addChild(mouth)
        GameTheme.pulse(node: mouth, minAlpha: 0.65, maxAlpha: 1.0, duration: 0.35)

        let edgeY = isTop ? -pipe.size.height / 2 + 6 : pipe.size.height / 2 - 6
        shooter.position = CGPoint(x: -pipe.size.width * 0.12, y: edgeY)
        pipe.addChild(shooter)

        let shoot = SKAction.run { [weak shooter, weak pipe] in
            guard let shooter, let pipe else { return }
            spawnFireball(from: shooter, on: pipe, theme: theme)
        }

        shooter.run(.sequence([
            .wait(forDuration: TimeInterval.random(in: 0.45...0.65)),
            shoot,
        ]), withKey: "shoot")
    }

    /// Fire is parented to the pipe and moves straight left in local space so it never homes on the player.
    private static func spawnFireball(
        from shooter: SKNode,
        on pipe: SKSpriteNode,
        theme: ThemePalette
    ) {
        let ball = SKShapeNode(ellipseOf: CGSize(width: 20, height: 14))
        ball.fillColor = theme.accentSecondary
        ball.strokeColor = theme.accent
        ball.lineWidth = 2
        ball.name = fireballName
        ball.position = shooter.position
        ball.zPosition = 8

        let core = SKShapeNode(ellipseOf: CGSize(width: 9, height: 6))
        core.fillColor = theme.accentGlow
        core.strokeColor = .clear
        core.zPosition = 1
        ball.addChild(core)

        let body = SKPhysicsBody(circleOfRadius: 7)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.fire
        body.contactTestBitMask = PhysicsCategory.bird
        body.collisionBitMask = PhysicsCategory.none
        ball.physicsBody = body

        pipe.addChild(ball)

        let travel = GameConstants.fireballTravelDistance
        let duration = TimeInterval(travel / GameConstants.fireballSpeed)

        ball.run(.sequence([
            .group([
                .moveBy(x: -travel, y: 0, duration: duration),
                .sequence([
                    .scale(to: 1.06, duration: duration * 0.2),
                    .scale(to: 0.94, duration: duration * 0.8),
                ]),
            ]),
            .removeFromParent(),
        ]))
    }

    private static func makeMouth(theme: ThemePalette) -> SKNode {
        let mouth = SKNode()

        let flame = SKShapeNode(path: flamePath(width: 14, height: 18))
        flame.fillColor = theme.accentSecondary
        flame.strokeColor = theme.accent
        flame.lineWidth = 1.5
        mouth.addChild(flame)

        let tip = SKShapeNode(circleOfRadius: 3)
        tip.fillColor = theme.accentGlow
        tip.strokeColor = .clear
        tip.position = CGPoint(x: -8, y: 0)
        mouth.addChild(tip)

        return mouth
    }

    private static func flamePath(width: CGFloat, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: -width / 2, y: 0),
            control: CGPoint(x: 0, y: height)
        )
        path.closeSubpath()
        return path
    }
}
