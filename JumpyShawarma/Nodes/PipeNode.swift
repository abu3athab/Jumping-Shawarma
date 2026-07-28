import SpriteKit

enum PipeNode {
    static let pipeName = "pipe"
    static let scoreZoneName = "scoreZone"
    static let scoredZoneName = "scored"
    static let capHitboxName = "pipeCapHitbox"
    static let bodyHitboxName = "pipeBodyHitbox"

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

    private static let minBodyHeight: CGFloat = 44

    static func preloadTextures() {
        shawarmaTheme.capTop.preload {}
        shawarmaTheme.capBottom.preload {}
        shawarmaTheme.body.preload {}
        [shawarmaTheme.capTop, shawarmaTheme.capBottom, shawarmaTheme.body].forEach {
            $0.filteringMode = .linear
        }
    }

    static func makePipe(size: CGSize, isTop: Bool) -> SKSpriteNode {
        makeSpritePipe(size: size, isTop: isTop, assets: shawarmaTheme)
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

        attachPhysics(
            to: pipe,
            pipeSize: size,
            capWidth: capWidth,
            capHeight: capHeight,
            bodyHeight: bodyHeight,
            columnWidth: pipeWidth,
            isTop: isTop
        )

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

    private static func attachPhysics(
        to pipe: SKSpriteNode,
        pipeSize: CGSize,
        capWidth: CGFloat,
        capHeight: CGFloat,
        bodyHeight: CGFloat,
        columnWidth: CGFloat,
        isTop: Bool
    ) {
        let capCenterY = isTop
            ? -pipeSize.height / 2 + capHeight / 2
            : pipeSize.height / 2 - capHeight / 2

        let capBody = SKPhysicsBody(
            rectangleOf: CGSize(width: capWidth, height: capHeight),
            center: CGPoint(x: 0, y: capCenterY)
        )

        var bodies = [capBody]

        let capHitbox = SKSpriteNode(color: .clear, size: CGSize(width: capWidth, height: capHeight))
        capHitbox.name = capHitboxName
        capHitbox.position = CGPoint(x: 0, y: capCenterY)
        pipe.addChild(capHitbox)

        if bodyHeight > 0.5 {
            let bodyCenterY = isTop
                ? -pipeSize.height / 2 + capHeight + bodyHeight / 2
                : pipeSize.height / 2 - capHeight - bodyHeight / 2

            let columnBody = SKPhysicsBody(
                rectangleOf: CGSize(width: columnWidth, height: bodyHeight),
                center: CGPoint(x: 0, y: bodyCenterY)
            )
            bodies.append(columnBody)

            let bodyHitbox = SKSpriteNode(color: .clear, size: CGSize(width: columnWidth, height: bodyHeight))
            bodyHitbox.name = bodyHitboxName
            bodyHitbox.position = CGPoint(x: 0, y: bodyCenterY)
            pipe.addChild(bodyHitbox)
        }

        let combined = SKPhysicsBody(bodies: bodies)
        combined.isDynamic = false
        combined.restitution = 0
        combined.categoryBitMask = PhysicsCategory.pipe
        combined.contactTestBitMask = PhysicsCategory.bird
        combined.collisionBitMask = PhysicsCategory.none
        pipe.physicsBody = combined
    }

    static func intersectsBird(_ birdFrame: CGRect, in scene: SKScene) -> Bool {
        var hit = false
        for hitboxName in [capHitboxName, bodyHitboxName] {
            scene.enumerateChildNodes(withName: hitboxName) { node, stop in
                guard birdFrame.intersects(node.calculateAccumulatedFrame()) else { return }
                hit = true
                stop.pointee = true
            }
            if hit { break }
        }
        return hit
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
