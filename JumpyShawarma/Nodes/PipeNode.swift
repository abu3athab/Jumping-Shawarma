import SpriteKit

enum PipeNode {
    static let pipeName = "pipe"
    static let scoreZoneName = "scoreZone"
    static let scoredZoneName = "scored"

    private struct SpritePipeTheme {
        let capTop: SKTexture
        let capBottom: SKTexture
        let body: SKTexture
        let capDisplayScale: CGFloat
        let bottomCapWidthRatio: CGFloat
        let maxCapHeight: CGFloat
    }

    private static let shawarmaTheme = SpritePipeTheme(
        capTop: SKTexture(imageNamed: "ShawarmaPipeTop"),
        capBottom: SKTexture(imageNamed: "ShawarmaPipeBottom"),
        body: SKTexture(imageNamed: "ShawarmaPipeBody"),
        capDisplayScale: 0.48,
        bottomCapWidthRatio: 1.12,
        maxCapHeight: 68
    )

    private static let rooftopObstacleNames = [
        "RooftopObstacle00",
        "RooftopObstacle01",
        "RooftopObstacle03",
        "RooftopObstacle08",
        "RooftopObstacle11",
        "RooftopRotisserie",
    ]

    private static let rooftopObstacleTextures: [SKTexture] = rooftopObstacleNames.map {
        SKTexture(imageNamed: $0)
    }

    private static let stallTowerTextures: [SKTexture] = [
        SKTexture(imageNamed: "StallIngredientTower"),
        SKTexture(imageNamed: "StallRotisserieTower"),
        SKTexture(imageNamed: "StallPantryTower"),
    ]

    static let streetStallVariantCount = 3
    static var rooftopVariantCount: Int { rooftopObstacleTextures.count }

    private static let stallTowerLayoutSize = CGSize(width: 127, height: 375)
    private static let rooftopLayoutSize = CGSize(width: 130, height: 280)

    private static let minBodyHeight: CGFloat = 44

    static func preloadTextures() {
        shawarmaTheme.capTop.preload {}
        shawarmaTheme.capBottom.preload {}
        shawarmaTheme.body.preload {}
        [shawarmaTheme.capTop, shawarmaTheme.capBottom, shawarmaTheme.body].forEach {
            $0.filteringMode = .linear
        }

        rooftopObstacleTextures.forEach { texture in
            texture.preload {}
            texture.filteringMode = .linear
        }

        stallTowerTextures.forEach { texture in
            texture.preload {}
            texture.filteringMode = .linear
        }
    }

    static func makePipe(
        size: CGSize,
        isTop: Bool,
        theme: ThemePalette,
        stallVariant: Int = 0,
        pairLayoutHeight: CGFloat? = nil
    ) -> SKSpriteNode {
        let layoutHeight = pairLayoutHeight ?? size.height

        switch theme.id {
        case .nightAlley:
            return makeSpritePipe(size: size, isTop: isTop, assets: shawarmaTheme)
        case .downtownRush:
            let index = ((stallVariant % stallTowerTextures.count) + stallTowerTextures.count)
                % stallTowerTextures.count
            return makeFullTowerPipe(
                size: size,
                isTop: isTop,
                texture: stallTowerTextures[index],
                layoutHeight: layoutHeight,
                referenceSize: stallTowerLayoutSize
            )
        case .rooftopShift:
            let index = ((stallVariant % rooftopObstacleTextures.count) + rooftopObstacleTextures.count)
                % rooftopObstacleTextures.count
            return makeFullTowerPipe(
                size: size,
                isTop: isTop,
                texture: rooftopObstacleTextures[index],
                layoutHeight: layoutHeight,
                referenceSize: rooftopLayoutSize
            )
        }
    }

    private static func makeFullTowerPipe(
        size: CGSize,
        isTop: Bool,
        texture: SKTexture,
        layoutHeight: CGFloat,
        referenceSize: CGSize
    ) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachPhysics(to: pipe, size: size)

        let crop = SKCropNode()
        crop.zPosition = 1
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        pipe.addChild(crop)

        let textureSize = texture.size()
        guard textureSize.width > 0, textureSize.height > 0 else { return pipe }

        let fillScale = max(
            size.width / referenceSize.width,
            layoutHeight / referenceSize.height
        )
        let displaySize = CGSize(
            width: textureSize.width * fillScale,
            height: textureSize.height * fillScale
        )

        let tower = SKSpriteNode(texture: texture, size: displaySize)
        tower.zPosition = 1

        if isTop {
            tower.position = CGPoint(x: 0, y: -size.height / 2 + displaySize.height / 2)
        } else {
            tower.position = CGPoint(x: 0, y: size.height / 2 - displaySize.height / 2)
        }

        crop.addChild(tower)
        return pipe
    }

    private static func makeSpritePipe(size: CGSize, isTop: Bool, assets: SpritePipeTheme) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachPhysics(to: pipe, size: size)

        let capTexture = isTop ? assets.capTop : assets.capBottom
        let pipeWidth = size.width
        let naturalCapHeight = naturalCapHeight(
            for: capTexture,
            width: pipeWidth,
            isTop: isTop,
            assets: assets
        )
        let capHeight = resolvedCapHeight(naturalHeight: naturalCapHeight, pipeHeight: size.height, assets: assets)
        let capWidth = (isTop ? pipeWidth : pipeWidth * assets.bottomCapWidthRatio)
            * (capHeight / naturalCapHeight)
        let bodyHeight = max(0, size.height - capHeight)

        let crop = SKCropNode()
        crop.zPosition = 1
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        pipe.addChild(crop)

        let cap = SKSpriteNode(texture: capTexture, size: CGSize(width: capWidth, height: capHeight))
        cap.zPosition = 2

        if isTop {
            cap.position = CGPoint(x: 0, y: -size.height / 2 + capHeight / 2)
            crop.addChild(cap)

            if bodyHeight > 0 {
                let bodyCenterY = -size.height / 2 + capHeight + bodyHeight / 2
                addTiledBody(to: crop, texture: assets.body, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
            }
        } else {
            cap.position = CGPoint(x: 0, y: size.height / 2 - capHeight / 2)
            crop.addChild(cap)

            if bodyHeight > 0 {
                let bodyCenterY = size.height / 2 - capHeight - bodyHeight / 2
                addTiledBody(to: crop, texture: assets.body, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
            }
        }

        return pipe
    }

    private static func naturalCapHeight(
        for texture: SKTexture,
        width: CGFloat,
        isTop: Bool,
        assets: SpritePipeTheme
    ) -> CGFloat {
        let capWidth = isTop ? width : width * assets.bottomCapWidthRatio
        return capWidth * (texture.size().height / texture.size().width) * assets.capDisplayScale
    }

    private static func resolvedCapHeight(
        naturalHeight: CGFloat,
        pipeHeight: CGFloat,
        assets: SpritePipeTheme
    ) -> CGFloat {
        min(naturalHeight, assets.maxCapHeight, max(28, pipeHeight - minBodyHeight))
    }

    private static func addTiledBody(
        to pipe: SKNode,
        texture: SKTexture,
        width: CGFloat,
        height: CGFloat,
        centerY: CGFloat
    ) {
        let textureSize = texture.size()
        let segmentHeight = width * (textureSize.height / textureSize.width)
        let segmentCount = max(1, Int(ceil(height / segmentHeight)))
        let bottomEdge = centerY - height / 2

        for index in 0..<segmentCount {
            let segmentTop = bottomEdge + CGFloat(segmentCount - index) * segmentHeight
            let segmentBottom = max(bottomEdge, segmentTop - segmentHeight)
            let segmentActualHeight = segmentTop - segmentBottom
            guard segmentActualHeight > 0.5 else { continue }

            let segment = SKSpriteNode(
                texture: texture,
                size: CGSize(width: width, height: segmentActualHeight)
            )
            segment.position = CGPoint(x: 0, y: segmentBottom + segmentActualHeight / 2)
            segment.zPosition = 1
            pipe.addChild(segment)
        }
    }

    private static func attachPhysics(to pipe: SKSpriteNode, size: CGSize) {
        pipe.physicsBody = SKPhysicsBody(rectangleOf: size)
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird
    }

    static func makeScoreZone(at position: CGPoint, gapHeight: CGFloat) -> SKNode {
        let zone = SKNode()
        zone.position = position
        zone.name = scoreZoneName
        zone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 8, height: gapHeight))
        zone.physicsBody?.isDynamic = false
        zone.physicsBody?.categoryBitMask = PhysicsCategory.score
        zone.physicsBody?.contactTestBitMask = PhysicsCategory.bird
        zone.physicsBody?.collisionBitMask = PhysicsCategory.none
        return zone
    }
}
