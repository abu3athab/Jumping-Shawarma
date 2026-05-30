import SpriteKit

enum BackgroundBuilder {
    static func add(to scene: SKScene, theme: ThemePalette) {
        scene.backgroundColor = theme.background

        switch theme.id {
        case .nightAlley:
            addStallSilhouettes(to: scene, theme: theme)
            addStringLights(to: scene, theme: theme)
        case .downtownRush:
            addCitySilhouettes(to: scene, theme: theme)
            addNeonSigns(to: scene, theme: theme)
        }
    }

    private static func addStallSilhouettes(to scene: SKScene, theme: ThemePalette) {
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
            body.fillColor = theme.silhouette
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
            awning.fillColor = theme.awning.withAlphaComponent(0.45)
            awning.strokeColor = .clear
            awning.zPosition = 1
            body.addChild(awning)

            let window = SKShapeNode(rectOf: CGSize(width: stallWidth * 0.35, height: 18), cornerRadius: 3)
            window.fillColor = theme.accentGlow
            window.strokeColor = .clear
            window.position = CGPoint(x: 0, y: -stall.height * 0.08)
            window.zPosition = 2
            GameTheme.pulse(node: window, minAlpha: 0.35, maxAlpha: 0.85, duration: 1.4)
            body.addChild(window)
        }
    }

    private static func addStringLights(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let y = scene.size.height - 72
        let bulbColors: [SKColor] = [
            theme.accent,
            theme.accentSecondary,
            GameTheme.color(0.95, 0.3, 0.28),
            theme.textPrimary,
        ]

        let wire = SKShapeNode()
        let wirePath = CGMutablePath()
        wirePath.move(to: CGPoint(x: 24, y: y))
        wirePath.addQuadCurve(to: CGPoint(x: width - 24, y: y - 8), control: CGPoint(x: width / 2, y: y + 26))
        wire.path = wirePath
        wire.strokeColor = theme.wire
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
            cord.fillColor = theme.metalMid
            cord.strokeColor = .clear
            cord.position = CGPoint(x: x, y: bulbY + 8)
            cord.zPosition = -11
            scene.addChild(cord)

            let bulb = SKShapeNode(circleOfRadius: 5)
            bulb.fillColor = bulbColors[index % bulbColors.count]
            bulb.strokeColor = theme.textPrimary.withAlphaComponent(0.35)
            bulb.lineWidth = 1
            bulb.position = CGPoint(x: x, y: bulbY)
            bulb.zPosition = -10
            GameTheme.pulse(node: bulb, minAlpha: 0.5, maxAlpha: 1.0, duration: 0.7 + Double(index) * 0.08)
            scene.addChild(bulb)
        }
    }

    private static func addCitySilhouettes(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let groundTop = GameConstants.groundHeight + 20

        let buildings: [(xRatio: CGFloat, widthRatio: CGFloat, height: CGFloat)] = [
            (0.04, 0.18, 140),
            (0.22, 0.14, 96),
            (0.38, 0.2, 168),
            (0.6, 0.16, 118),
            (0.78, 0.22, 152),
        ]

        for building in buildings {
            let buildingWidth = width * building.widthRatio
            let body = SKShapeNode(rectOf: CGSize(width: buildingWidth, height: building.height), cornerRadius: 3)
            body.fillColor = theme.silhouette
            body.strokeColor = theme.metalLight.withAlphaComponent(0.15)
            body.lineWidth = 1
            body.position = CGPoint(
                x: width * building.xRatio + buildingWidth / 2,
                y: groundTop + building.height / 2
            )
            body.zPosition = -20
            scene.addChild(body)

            let windowColumns = 3
            let windowRows = max(2, Int(building.height / 36))
            for row in 0..<windowRows {
                for column in 0..<windowColumns {
                    let window = SKShapeNode(rectOf: CGSize(width: 14, height: 18), cornerRadius: 2)
                    window.fillColor = (row + column).isMultiple(of: 2)
                        ? theme.accentGlow
                        : theme.accentSecondary.withAlphaComponent(0.35)
                    window.strokeColor = .clear
                    window.position = CGPoint(
                        x: -buildingWidth * 0.22 + CGFloat(column) * buildingWidth * 0.22,
                        y: -building.height * 0.28 + CGFloat(row) * 32
                    )
                    window.zPosition = 1
                    if (row + column).isMultiple(of: 2) {
                        GameTheme.pulse(node: window, minAlpha: 0.25, maxAlpha: 0.8, duration: 1.1 + Double(row) * 0.1)
                    }
                    body.addChild(window)
                }
            }
        }
    }

    private static func addNeonSigns(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let y = scene.size.height - 88

        let signs: [(xRatio: CGFloat, width: CGFloat, color: SKColor)] = [
            (0.12, 70, theme.accent),
            (0.42, 92, theme.accentSecondary),
            (0.72, 64, theme.accent),
        ]

        for sign in signs {
            let x = width * sign.xRatio
            let board = SKShapeNode(rectOf: CGSize(width: sign.width, height: 10), cornerRadius: 5)
            board.fillColor = sign.color.withAlphaComponent(0.25)
            board.strokeColor = sign.color
            board.lineWidth = 2
            board.position = CGPoint(x: x, y: y)
            board.zPosition = -10
            GameTheme.pulse(node: board, minAlpha: 0.45, maxAlpha: 1.0, duration: 0.9)
            scene.addChild(board)

            let glow = SKShapeNode(rectOf: CGSize(width: sign.width + 8, height: 16), cornerRadius: 8)
            glow.fillColor = sign.color.withAlphaComponent(0.08)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: x, y: y)
            glow.zPosition = -11
            scene.addChild(glow)
        }
    }
}
