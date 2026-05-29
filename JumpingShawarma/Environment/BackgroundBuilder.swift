import SpriteKit

enum BackgroundBuilder {
    static func add(to scene: SKScene) {
        scene.backgroundColor = GameTheme.background
        addStallSilhouettes(to: scene)
        addStringLights(to: scene)
    }

    private static func addStallSilhouettes(to scene: SKScene) {
        let width = scene.size.width
        let groundTop = GameConstants.groundHeight + 28

        let stalls: [(xRatio: CGFloat, widthRatio: CGFloat, height: CGFloat)] = [
            (0.08, 0.22, 110),
            (0.34, 0.18, 88),
            (0.58, 0.24, 124),
            (0.82, 0.2, 96),
        ]

        for stall in stalls {
            let stallWidth = width * stall.widthRatio
            let body = SKShapeNode(rectOf: CGSize(width: stallWidth, height: stall.height), cornerRadius: 4)
            body.fillColor = GameTheme.color(0.08, 0.05, 0.06, 0.55)
            body.strokeColor = .clear
            body.position = CGPoint(
                x: width * stall.xRatio + stallWidth / 2,
                y: groundTop + stall.height / 2
            )
            body.zPosition = -20
            scene.addChild(body)

            let awningPath = CGMutablePath()
            awningPath.move(to: CGPoint(x: -stallWidth / 2 - 6, y: stall.height / 2))
            awningPath.addLine(to: CGPoint(x: stallWidth / 2 + 6, y: stall.height / 2))
            awningPath.addLine(to: CGPoint(x: stallWidth / 2, y: stall.height / 2 + 22))
            awningPath.addLine(to: CGPoint(x: -stallWidth / 2, y: stall.height / 2 + 18))
            awningPath.closeSubpath()

            let awning = SKShapeNode(path: awningPath)
            awning.fillColor = GameTheme.awning.withAlphaComponent(0.45)
            awning.strokeColor = .clear
            awning.zPosition = 1
            body.addChild(awning)

            let window = SKShapeNode(rectOf: CGSize(width: stallWidth * 0.35, height: 18), cornerRadius: 3)
            window.fillColor = GameTheme.emberGlow
            window.strokeColor = .clear
            window.position = CGPoint(x: 0, y: -stall.height * 0.08)
            window.zPosition = 2
            GameTheme.pulse(node: window, minAlpha: 0.35, maxAlpha: 0.85, duration: 1.4)
            body.addChild(window)
        }
    }

    private static func addStringLights(to scene: SKScene) {
        let width = scene.size.width
        let y = scene.size.height - 72
        let bulbColors: [SKColor] = [
            GameTheme.gold,
            GameTheme.ember,
            GameTheme.color(0.95, 0.3, 0.28),
            GameTheme.cream,
        ]

        let wire = SKShapeNode()
        let wirePath = CGMutablePath()
        wirePath.move(to: CGPoint(x: 24, y: y))
        wirePath.addQuadCurve(to: CGPoint(x: width - 24, y: y - 8), control: CGPoint(x: width / 2, y: y + 26))
        wire.path = wirePath
        wire.strokeColor = GameTheme.color(0.2, 0.16, 0.14, 0.7)
        wire.lineWidth = 2
        wire.zPosition = -12
        scene.addChild(wire)

        let bulbCount = 7
        for index in 0..<bulbCount {
            let t = CGFloat(index) / CGFloat(bulbCount - 1)
            let x = 24 + (width - 48) * t
            let sag = sin(t * .pi) * 18
            let bulbY = y - 8 * t - sag

            let cord = SKShapeNode(rectOf: CGSize(width: 2, height: 10))
            cord.fillColor = GameTheme.metalMid
            cord.strokeColor = .clear
            cord.position = CGPoint(x: x, y: bulbY + 8)
            cord.zPosition = -11
            scene.addChild(cord)

            let bulb = SKShapeNode(circleOfRadius: 5)
            bulb.fillColor = bulbColors[index % bulbColors.count]
            bulb.strokeColor = GameTheme.cream.withAlphaComponent(0.35)
            bulb.lineWidth = 1
            bulb.position = CGPoint(x: x, y: bulbY)
            bulb.zPosition = -10
            GameTheme.pulse(node: bulb, minAlpha: 0.5, maxAlpha: 1.0, duration: 0.7 + Double(index) * 0.08)
            scene.addChild(bulb)
        }
    }
}
