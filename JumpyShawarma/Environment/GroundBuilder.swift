import SpriteKit

enum GroundBuilder {
    static func make(in sceneSize: CGSize, theme: ThemePalette) -> SKNode {
        let groundHeight = GameConstants.groundHeight

        let container = SKNode()
        container.position = CGPoint(x: sceneSize.width / 2, y: groundHeight / 2)

        let groundBody = SKSpriteNode(color: .clear, size: CGSize(width: sceneSize.width * 2, height: groundHeight))
        groundBody.zPosition = 5
        groundBody.physicsBody = SKPhysicsBody(rectangleOf: groundBody.size)
        groundBody.physicsBody?.isDynamic = false
        groundBody.physicsBody?.categoryBitMask = PhysicsCategory.ground
        groundBody.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        container.addChild(groundBody)

        addSurface(to: groundBody, sceneWidth: sceneSize.width * 2, height: groundHeight, theme: theme)

        let glowStrip = SKSpriteNode(
            color: theme.groundGlow,
            size: CGSize(width: sceneSize.width * 2, height: 10)
        )
        glowStrip.position = CGPoint(x: 0, y: groundHeight / 2 - 8)
        glowStrip.zPosition = 6
        GameTheme.pulse(node: glowStrip, minAlpha: 0.25, maxAlpha: 0.55, duration: 1.1)
        container.addChild(glowStrip)

        let counterLip = SKShapeNode(rectOf: CGSize(width: sceneSize.width * 2, height: 14), cornerRadius: 2)
        counterLip.fillColor = theme.counter
        counterLip.strokeColor = theme.metalLight.withAlphaComponent(0.5)
        counterLip.lineWidth = 1
        counterLip.position = CGPoint(x: 0, y: groundHeight / 2 + 1)
        counterLip.zPosition = 7
        container.addChild(counterLip)

        return container
    }

    private static func addSurface(
        to groundBody: SKSpriteNode,
        sceneWidth: CGFloat,
        height: CGFloat,
        theme: ThemePalette
    ) {
        let tileWidth: CGFloat = 26
        let tileHeight: CGFloat = 16
        let columns = Int(sceneWidth / tileWidth) + 1
        let rows = Int(height / tileHeight)

        for row in 0..<rows {
            for column in 0..<columns {
                let offset = row.isMultiple(of: 2) ? tileWidth / 2 : 0
                let tile = SKShapeNode(rectOf: CGSize(width: tileWidth - 3, height: tileHeight - 3), cornerRadius: 2)
                tile.fillColor = (column + row).isMultiple(of: 2) ? theme.groundDark : theme.groundLight
                tile.strokeColor = theme.metalDark.withAlphaComponent(0.35)
                tile.lineWidth = 1
                tile.position = CGPoint(
                    x: -sceneWidth / 2 + CGFloat(column) * tileWidth + tileWidth / 2 + offset,
                    y: -height / 2 + CGFloat(row) * tileHeight + tileHeight / 2
                )
                tile.zPosition = 1
                groundBody.addChild(tile)
            }
        }
    }

    static func reposition(_ ground: SKNode, sceneWidth: CGFloat) {
        ground.position = CGPoint(x: sceneWidth / 2, y: GameConstants.groundHeight / 2)
    }
}
