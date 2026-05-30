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

    private static let stallTowerTextures: [SKTexture] = [
        SKTexture(imageNamed: "StallIngredientTower"),
        SKTexture(imageNamed: "StallRotisserieTower"),
        SKTexture(imageNamed: "StallPantryTower"),
    ]

    static let streetStallVariantCount = 3

    private static let minBodyHeight: CGFloat = 44

    static func preloadTextures() {
        shawarmaTheme.capTop.preload {}
        shawarmaTheme.capBottom.preload {}
        shawarmaTheme.body.preload {}
        [shawarmaTheme.capTop, shawarmaTheme.capBottom, shawarmaTheme.body].forEach {
            $0.filteringMode = .linear
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
        stallVariant: Int = 0
    ) -> SKSpriteNode {
        switch theme.id {
        case .nightAlley:
            return makeSpritePipe(size: size, isTop: isTop, assets: shawarmaTheme)
        case .downtownRush:
            let index = ((stallVariant % stallTowerTextures.count) + stallTowerTextures.count)
                % stallTowerTextures.count
            return makeStallTowerPipe(size: size, isTop: isTop, texture: stallTowerTextures[index])
        case .rooftopShift:
            return makeRooftopPipe(size: size, isTop: isTop, theme: theme)
        }
    }

    private static func makeStallTowerPipe(size: CGSize, isTop: Bool, texture: SKTexture) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3

        let crop = SKCropNode()
        crop.zPosition = 1
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        pipe.addChild(crop)

        let textureSize = texture.size()
        guard textureSize.width > 0, textureSize.height > 0 else {
            attachRectPhysics(to: pipe, size: size)
            return pipe
        }

        let fillScale = max(size.width / textureSize.width, size.height / textureSize.height)
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
        addTextureCollider(to: pipe, texture: texture, size: displaySize, position: tower.position)

        return pipe
    }

    private static func makeSpritePipe(size: CGSize, isTop: Bool, assets: SpritePipeTheme) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3

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
            addTextureCollider(to: pipe, texture: capTexture, size: cap.size, position: cap.position)

            if bodyHeight > 0 {
                let bodyCenterY = -size.height / 2 + capHeight + bodyHeight / 2
                addTiledBody(to: crop, texture: assets.body, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
                addTextureCollider(
                    to: pipe,
                    texture: assets.body,
                    size: CGSize(width: pipeWidth, height: bodyHeight),
                    position: CGPoint(x: 0, y: bodyCenterY)
                )
            }
        } else {
            cap.position = CGPoint(x: 0, y: size.height / 2 - capHeight / 2)
            crop.addChild(cap)
            addTextureCollider(to: pipe, texture: capTexture, size: cap.size, position: cap.position)

            if bodyHeight > 0 {
                let bodyCenterY = size.height / 2 - capHeight - bodyHeight / 2
                addTiledBody(to: crop, texture: assets.body, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
                addTextureCollider(
                    to: pipe,
                    texture: assets.body,
                    size: CGSize(width: pipeWidth, height: bodyHeight),
                    position: CGPoint(x: 0, y: bodyCenterY)
                )
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

    private static func makeRooftopPipe(size: CGSize, isTop: Bool, theme: ThemePalette) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachRectPhysics(to: pipe, size: size)

        let panelCount = max(2, Int(size.height / 48))
        let panelHeight = size.height / CGFloat(panelCount)

        for index in 0..<panelCount {
            let y = -size.height / 2 + panelHeight / 2 + CGFloat(index) * panelHeight
            let panel = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: panelHeight - 5), cornerRadius: 5)
            panel.fillColor = index.isMultiple(of: 2) ? theme.metalMid : theme.metalDark
            panel.strokeColor = theme.metalLight.withAlphaComponent(0.4)
            panel.lineWidth = 1.5
            panel.position = CGPoint(x: 0, y: y)
            panel.zPosition = 1
            pipe.addChild(panel)

            let ventSlot = SKShapeNode(rectOf: CGSize(width: size.width - 16, height: 4), cornerRadius: 2)
            ventSlot.fillColor = theme.accentGlow
            ventSlot.strokeColor = .clear
            ventSlot.position = CGPoint(x: 0, y: y + panelHeight * 0.12)
            ventSlot.zPosition = 2
            if index == panelCount / 2 {
                GameTheme.pulse(node: ventSlot, minAlpha: 0.35, maxAlpha: 0.85, duration: 0.7)
            }
            pipe.addChild(ventSlot)
        }

        let capY = isTop ? -size.height / 2 + 14 : size.height / 2 - 14
        let cap = SKShapeNode(rectOf: CGSize(width: size.width + 6, height: 16), cornerRadius: 4)
        cap.fillColor = theme.metalLight.withAlphaComponent(0.85)
        cap.strokeColor = theme.accent.withAlphaComponent(0.7)
        cap.lineWidth = 2
        cap.position = CGPoint(x: 0, y: capY)
        cap.zPosition = 3
        pipe.addChild(cap)

        if isTop {
            let chain = SKShapeNode(rectOf: CGSize(width: 3, height: 18))
            chain.fillColor = theme.metalLight
            chain.strokeColor = .clear
            chain.position = CGPoint(x: 0, y: capY - 20)
            chain.zPosition = 4
            pipe.addChild(chain)
        } else {
            let steam = SKShapeNode(circleOfRadius: 6)
            steam.fillColor = GameTheme.steam
            steam.strokeColor = .clear
            steam.position = CGPoint(x: 0, y: capY + 16)
            steam.zPosition = 4
            GameTheme.pulse(node: steam, minAlpha: 0.15, maxAlpha: 0.45, duration: 1.0)
            pipe.addChild(steam)
        }

        return pipe
    }

    private static func attachRectPhysics(to pipe: SKSpriteNode, size: CGSize) {
        let body = SKPhysicsBody(rectangleOf: size)
        configurePipePhysics(body)
        pipe.physicsBody = body
    }

    private static func addTextureCollider(
        to pipe: SKNode,
        texture: SKTexture,
        size: CGSize,
        position: CGPoint
    ) {
        let collider = SKNode()
        collider.position = position
        let body = SKPhysicsBody(texture: texture, size: size)
        configurePipePhysics(body)
        collider.physicsBody = body
        pipe.addChild(collider)
    }

    private static func configurePipePhysics(_ body: SKPhysicsBody) {
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.pipe
        body.contactTestBitMask = PhysicsCategory.bird
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
