import SpriteKit

enum BackgroundBuilder {
    private static let stringLightsDrop: CGFloat = 72
    private static let neonSignsDrop: CGFloat = 88

    static func add(to scene: SKScene, theme: ThemePalette) {
        scene.backgroundColor = theme.background

        switch theme.id {
        case .nightAlley:
            addStallSilhouettes(to: scene, theme: theme)
            addTopDecorations(to: scene, drop: stringLightsDrop) {
                addStringLights(to: $0, sceneWidth: scene.size.width, theme: theme)
            }
        case .closingTime:
            addClosingTimeStallSilhouettes(to: scene, theme: theme)
            addClosingTimeGlow(to: scene, theme: theme)
            addTopDecorations(to: scene, drop: stringLightsDrop) {
                addClosingTimeStringLights(to: $0, sceneWidth: scene.size.width, theme: theme)
            }
        case .downtownRush:
            addCitySilhouettes(to: scene, theme: theme)
            addTopDecorations(to: scene, drop: neonSignsDrop) {
                addNeonSigns(to: $0, sceneWidth: scene.size.width, theme: theme)
            }
        case .rooftopShift:
            addRooftopSilhouettes(to: scene, theme: theme)
            addSunsetGlow(to: scene, theme: theme)
        case .forgeFlames:
            addForgeSilhouettes(to: scene, theme: theme)
            addForgeGlow(to: scene, theme: theme)
        }
    }

    static func applySafeArea(top: CGFloat, in scene: SKScene, theme: ThemePalette) {
        guard let decorations = scene.childNode(withName: "topDecorations") else { return }

        let drop: CGFloat
        switch theme.id {
        case .downtownRush: drop = neonSignsDrop
        case .nightAlley, .closingTime: drop = stringLightsDrop
        default: return
        }

        decorations.position = CGPoint(x: 0, y: scene.size.height - top - drop)
    }

    private static func addTopDecorations(
        to scene: SKScene,
        drop: CGFloat,
        build: (SKNode) -> Void
    ) {
        let root = SKNode()
        root.name = "topDecorations"
        root.zPosition = -15
        root.position = CGPoint(x: 0, y: scene.size.height - drop)
        scene.addChild(root)
        build(root)
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

    private static func addStringLights(to root: SKNode, sceneWidth width: CGFloat, theme: ThemePalette) {
        let y: CGFloat = 0
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
        wire.zPosition = 3
        root.addChild(wire)

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
            cord.zPosition = 4
            root.addChild(cord)

            let bulb = SKShapeNode(circleOfRadius: 5)
            bulb.fillColor = bulbColors[index % bulbColors.count]
            bulb.strokeColor = theme.textPrimary.withAlphaComponent(0.35)
            bulb.lineWidth = 1
            bulb.position = CGPoint(x: x, y: bulbY)
            bulb.zPosition = 5
            GameTheme.pulse(node: bulb, minAlpha: 0.5, maxAlpha: 1.0, duration: 0.7 + Double(index) * 0.08)
            root.addChild(bulb)
        }
    }

    private static func addClosingTimeStallSilhouettes(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let groundTop = GameConstants.groundHeight + 28

        let stalls: [(xRatio: CGFloat, widthRatio: CGFloat, height: CGFloat, lit: Bool)] = [
            (0.12, 0.24, 110, true),
            (0.48, 0.20, 96, false),
            (0.78, 0.22, 118, true),
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
            awning.fillColor = theme.awning.withAlphaComponent(stall.lit ? 0.35 : 0.18)
            awning.strokeColor = .clear
            awning.zPosition = 1
            body.addChild(awning)

            if stall.lit {
                let window = SKShapeNode(rectOf: CGSize(width: stallWidth * 0.35, height: 18), cornerRadius: 3)
                window.fillColor = theme.accentGlow
                window.strokeColor = .clear
                window.position = CGPoint(x: 0, y: -stall.height * 0.08)
                window.zPosition = 2
                GameTheme.pulse(node: window, minAlpha: 0.22, maxAlpha: 0.62, duration: 1.8)
                body.addChild(window)
            }
        }
    }

    private static func addClosingTimeGlow(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let height = scene.size.height

        let horizon = SKShapeNode(rectOf: CGSize(width: width + 40, height: height * 0.28))
        horizon.fillColor = theme.accentGlow.withAlphaComponent(0.10)
        horizon.strokeColor = .clear
        horizon.position = CGPoint(x: width / 2, y: height * 0.18)
        horizon.zPosition = -25
        scene.addChild(horizon)

        let lamp = SKShapeNode(circleOfRadius: 28)
        lamp.fillColor = theme.accentSecondary.withAlphaComponent(0.12)
        lamp.strokeColor = theme.accent.withAlphaComponent(0.22)
        lamp.lineWidth = 1.5
        lamp.position = CGPoint(x: width * 0.22, y: height * 0.62)
        lamp.zPosition = -22
        GameTheme.pulse(node: lamp, minAlpha: 0.45, maxAlpha: 0.85, duration: 1.6)
        scene.addChild(lamp)
    }

    private static func addClosingTimeStringLights(to root: SKNode, sceneWidth width: CGFloat, theme: ThemePalette) {
        let y: CGFloat = 0
        let litIndices: Set<Int> = [0, 2, 4, 6]

        let wire = SKShapeNode()
        let wirePath = CGMutablePath()
        wirePath.move(to: CGPoint(x: 24, y: y))
        wirePath.addQuadCurve(to: CGPoint(x: width - 24, y: y - 8), control: CGPoint(x: width / 2, y: y + 26))
        wire.path = wirePath
        wire.strokeColor = theme.wire
        wire.lineWidth = 2
        wire.zPosition = 3
        root.addChild(wire)

        let bulbCount = 7
        for index in 0..<bulbCount {
            let t = CGFloat(index) / CGFloat(bulbCount - 1)
            let x = 24 + (width - 48) * t
            let sag = sin(t * .pi) * 18
            let bulbY = y - 8 * t - sag
            let isLit = litIndices.contains(index)

            let cord = SKShapeNode(rectOf: CGSize(width: 2, height: 10))
            cord.fillColor = theme.metalMid
            cord.strokeColor = .clear
            cord.position = CGPoint(x: x, y: bulbY + 8)
            cord.zPosition = 4
            root.addChild(cord)

            let bulb = SKShapeNode(circleOfRadius: 5)
            bulb.fillColor = isLit ? theme.accent : theme.metalMid
            bulb.strokeColor = theme.textPrimary.withAlphaComponent(isLit ? 0.25 : 0.12)
            bulb.lineWidth = 1
            bulb.position = CGPoint(x: x, y: bulbY)
            bulb.zPosition = 5
            bulb.alpha = isLit ? 1.0 : 0.35
            if isLit {
                GameTheme.pulse(node: bulb, minAlpha: 0.35, maxAlpha: 0.75, duration: 1.2 + Double(index) * 0.1)
            }
            root.addChild(bulb)
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

    private static func addNeonSigns(to root: SKNode, sceneWidth width: CGFloat, theme: ThemePalette) {
        let y: CGFloat = 0

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
            board.zPosition = 5
            GameTheme.pulse(node: board, minAlpha: 0.45, maxAlpha: 1.0, duration: 0.9)
            root.addChild(board)

            let glow = SKShapeNode(rectOf: CGSize(width: sign.width + 8, height: 16), cornerRadius: 8)
            glow.fillColor = sign.color.withAlphaComponent(0.08)
            glow.strokeColor = .clear
            glow.position = CGPoint(x: x, y: y)
            glow.zPosition = 4
            root.addChild(glow)
        }
    }

    private static func addRooftopSilhouettes(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let groundTop = GameConstants.groundHeight + 24

        let parapets: [(xRatio: CGFloat, widthRatio: CGFloat, height: CGFloat)] = [
            (0.02, 0.28, 72),
            (0.3, 0.22, 58),
            (0.54, 0.26, 84),
            (0.8, 0.2, 64),
        ]

        for parapet in parapets {
            let parapetWidth = width * parapet.widthRatio
            let body = SKShapeNode(rectOf: CGSize(width: parapetWidth, height: parapet.height), cornerRadius: 3)
            body.fillColor = theme.silhouette
            body.strokeColor = theme.metalLight.withAlphaComponent(0.12)
            body.lineWidth = 1
            body.position = CGPoint(
                x: width * parapet.xRatio + parapetWidth / 2,
                y: groundTop + parapet.height / 2
            )
            body.zPosition = -20
            scene.addChild(body)

            let tank = SKShapeNode(rectOf: CGSize(width: parapetWidth * 0.22, height: 28), cornerRadius: 4)
            tank.fillColor = theme.metalMid.withAlphaComponent(0.85)
            tank.strokeColor = theme.metalLight.withAlphaComponent(0.25)
            tank.lineWidth = 1
            tank.position = CGPoint(x: parapetWidth * 0.18, y: parapet.height / 2 + 18)
            tank.zPosition = 1
            body.addChild(tank)
        }

        let tanks: [(xRatio: CGFloat, radius: CGFloat)] = [
            (0.18, 16),
            (0.48, 20),
            (0.76, 14),
        ]

        for tank in tanks {
            let waterTank = SKShapeNode(circleOfRadius: tank.radius)
            waterTank.fillColor = theme.metalMid.withAlphaComponent(0.7)
            waterTank.strokeColor = theme.accent.withAlphaComponent(0.35)
            waterTank.lineWidth = 1.5
            waterTank.position = CGPoint(x: width * tank.xRatio, y: groundTop + 118)
            waterTank.zPosition = -18
            scene.addChild(waterTank)
        }
    }

    private static func addSunsetGlow(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let height = scene.size.height

        let horizon = SKShapeNode(rectOf: CGSize(width: width + 40, height: height * 0.34))
        horizon.fillColor = theme.accentGlow.withAlphaComponent(0.12)
        horizon.strokeColor = .clear
        horizon.position = CGPoint(x: width / 2, y: height * 0.22)
        horizon.zPosition = -25
        scene.addChild(horizon)

        let sun = SKShapeNode(circleOfRadius: 34)
        sun.fillColor = theme.accent.withAlphaComponent(0.22)
        sun.strokeColor = theme.accentSecondary.withAlphaComponent(0.35)
        sun.lineWidth = 2
        sun.position = CGPoint(x: width * 0.78, y: height * 0.72)
        sun.zPosition = -22
        GameTheme.pulse(node: sun, minAlpha: 0.55, maxAlpha: 0.95, duration: 1.6)
        scene.addChild(sun)
    }

    private static func addForgeSilhouettes(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let groundTop = GameConstants.groundHeight + 24

        let furnaces: [(xRatio: CGFloat, widthRatio: CGFloat, height: CGFloat)] = [
            (0.04, 0.24, 96),
            (0.32, 0.2, 78),
            (0.56, 0.26, 108),
            (0.82, 0.18, 86),
        ]

        for furnace in furnaces {
            let furnaceWidth = width * furnace.widthRatio
            let body = SKShapeNode(rectOf: CGSize(width: furnaceWidth, height: furnace.height), cornerRadius: 4)
            body.fillColor = theme.silhouette
            body.strokeColor = theme.metalLight.withAlphaComponent(0.18)
            body.lineWidth = 1
            body.position = CGPoint(
                x: width * furnace.xRatio + furnaceWidth / 2,
                y: groundTop + furnace.height / 2
            )
            body.zPosition = -20
            scene.addChild(body)

            let chimney = SKShapeNode(rectOf: CGSize(width: furnaceWidth * 0.18, height: 36), cornerRadius: 3)
            chimney.fillColor = theme.metalMid.withAlphaComponent(0.9)
            chimney.strokeColor = theme.metalLight.withAlphaComponent(0.2)
            chimney.lineWidth = 1
            chimney.position = CGPoint(x: furnaceWidth * 0.22, y: furnace.height / 2 + 24)
            chimney.zPosition = 1
            body.addChild(chimney)

            let vent = SKShapeNode(rectOf: CGSize(width: furnaceWidth * 0.42, height: 14), cornerRadius: 3)
            vent.fillColor = theme.accentGlow
            vent.strokeColor = theme.accent.withAlphaComponent(0.45)
            vent.lineWidth = 1
            vent.position = CGPoint(x: 0, y: -furnace.height * 0.18)
            vent.zPosition = 2
            GameTheme.pulse(node: vent, minAlpha: 0.35, maxAlpha: 0.95, duration: 0.85)
            body.addChild(vent)
        }

        let emberSpots: [(xRatio: CGFloat, radius: CGFloat)] = [
            (0.2, 5),
            (0.44, 4),
            (0.68, 6),
            (0.88, 4),
        ]

        for spot in emberSpots {
            let ember = SKShapeNode(circleOfRadius: spot.radius)
            ember.fillColor = theme.accentSecondary
            ember.strokeColor = .clear
            ember.position = CGPoint(x: width * spot.xRatio, y: groundTop + 42)
            ember.zPosition = -17
            GameTheme.pulse(node: ember, minAlpha: 0.4, maxAlpha: 1.0, duration: 0.6 + Double(spot.radius) * 0.05)
            scene.addChild(ember)
        }
    }

    private static func addForgeGlow(to scene: SKScene, theme: ThemePalette) {
        let width = scene.size.width
        let height = scene.size.height

        let heat = SKShapeNode(rectOf: CGSize(width: width + 40, height: height * 0.38))
        heat.fillColor = theme.accentGlow.withAlphaComponent(0.14)
        heat.strokeColor = .clear
        heat.position = CGPoint(x: width / 2, y: height * 0.18)
        heat.zPosition = -25
        scene.addChild(heat)

        let flare = SKShapeNode(circleOfRadius: 48)
        flare.fillColor = theme.accent.withAlphaComponent(0.16)
        flare.strokeColor = theme.accentSecondary.withAlphaComponent(0.3)
        flare.lineWidth = 2
        flare.position = CGPoint(x: width * 0.22, y: height * 0.62)
        flare.zPosition = -22
        GameTheme.pulse(node: flare, minAlpha: 0.5, maxAlpha: 0.95, duration: 1.1)
        scene.addChild(flare)
    }
}
