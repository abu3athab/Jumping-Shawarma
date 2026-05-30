import SpriteKit

enum PipeNode {
    static let pipeName = "pipe"
    static let scoreZoneName = "scoreZone"
    static let scoredZoneName = "scored"

    private static let capTopTexture = SKTexture(imageNamed: "ShawarmaPipeTop")
    private static let capBottomTexture = SKTexture(imageNamed: "ShawarmaPipeBottom")
    private static let bodyTexture = SKTexture(imageNamed: "ShawarmaPipeBody")
    private static let capDisplayScale: CGFloat = 0.48
    private static let bottomCapWidthRatio: CGFloat = 1.12
    private static let maxCapHeight: CGFloat = 68
    private static let minBodyHeight: CGFloat = 44

    static func preloadTextures() {
        capTopTexture.preload {}
        capBottomTexture.preload {}
        bodyTexture.preload {}
        [capTopTexture, capBottomTexture, bodyTexture].forEach {
            $0.filteringMode = .linear
        }
    }

    static func makePipe(size: CGSize, isTop: Bool, theme: ThemePalette) -> SKSpriteNode {
        switch theme.id {
        case .nightAlley:
            return makeShawarmaPipe(size: size, isTop: isTop)
        case .downtownRush:
            return makeDeliveryPipe(size: size, isTop: isTop, theme: theme)
        case .rooftopShift:
            return makeRooftopPipe(size: size, isTop: isTop, theme: theme)
        }
    }

    private static func makeShawarmaPipe(size: CGSize, isTop: Bool) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachPhysics(to: pipe, size: size)

        let capTexture = isTop ? capTopTexture : capBottomTexture
        let pipeWidth = size.width
        let naturalCapHeight = naturalCapHeight(for: capTexture, width: pipeWidth, isTop: isTop)
        let capHeight = resolvedCapHeight(naturalHeight: naturalCapHeight, pipeHeight: size.height)
        let capWidth = (isTop ? pipeWidth : pipeWidth * bottomCapWidthRatio)
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
                addShawarmaBody(to: crop, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
            }
        } else {
            cap.position = CGPoint(x: 0, y: size.height / 2 - capHeight / 2)
            crop.addChild(cap)

            if bodyHeight > 0 {
                let bodyCenterY = size.height / 2 - capHeight - bodyHeight / 2
                addShawarmaBody(to: crop, width: pipeWidth, height: bodyHeight, centerY: bodyCenterY)
            }
        }

        return pipe
    }

    private static func naturalCapHeight(for texture: SKTexture, width: CGFloat, isTop: Bool) -> CGFloat {
        let capWidth = isTop ? width : width * bottomCapWidthRatio
        return capWidth * (texture.size().height / texture.size().width) * capDisplayScale
    }

    private static func resolvedCapHeight(naturalHeight: CGFloat, pipeHeight: CGFloat) -> CGFloat {
        min(naturalHeight, maxCapHeight, max(28, pipeHeight - minBodyHeight))
    }

    private static func addShawarmaBody(to pipe: SKNode, width: CGFloat, height: CGFloat, centerY: CGFloat) {
        let textureSize = bodyTexture.size()
        let segmentHeight = width * (textureSize.height / textureSize.width)
        let segmentCount = max(1, Int(ceil(height / segmentHeight)))
        let bottomEdge = centerY - height / 2

        for index in 0..<segmentCount {
            let segmentTop = bottomEdge + CGFloat(segmentCount - index) * segmentHeight
            let segmentBottom = max(bottomEdge, segmentTop - segmentHeight)
            let segmentActualHeight = segmentTop - segmentBottom
            guard segmentActualHeight > 0.5 else { continue }

            let segment = SKSpriteNode(
                texture: bodyTexture,
                size: CGSize(width: width, height: segmentActualHeight)
            )
            segment.position = CGPoint(x: 0, y: segmentBottom + segmentActualHeight / 2)
            segment.zPosition = 1
            pipe.addChild(segment)
        }
    }

    private static func makeDeliveryPipe(size: CGSize, isTop: Bool, theme: ThemePalette) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachPhysics(to: pipe, size: size)

        let stackCount = max(2, Int(size.height / 52))
        let boxHeight = size.height / CGFloat(stackCount)

        for index in 0..<stackCount {
            let y = -size.height / 2 + boxHeight / 2 + CGFloat(index) * boxHeight
            let box = SKShapeNode(rectOf: CGSize(width: size.width - 8, height: boxHeight - 4), cornerRadius: 4)
            box.fillColor = index.isMultiple(of: 2)
                ? GameTheme.color(0.45, 0.32, 0.22)
                : GameTheme.color(0.52, 0.38, 0.26)
            box.strokeColor = theme.metalLight.withAlphaComponent(0.35)
            box.lineWidth = 1.5
            box.position = CGPoint(x: 0, y: y)
            box.zPosition = 1
            pipe.addChild(box)

            let stripe = SKShapeNode(rectOf: CGSize(width: size.width - 16, height: 3), cornerRadius: 1)
            stripe.fillColor = index.isMultiple(of: 2) ? theme.accent : theme.accentSecondary
            stripe.strokeColor = .clear
            stripe.position = CGPoint(x: 0, y: y + boxHeight * 0.18)
            stripe.zPosition = 2
            if index == stackCount - 1 {
                GameTheme.pulse(node: stripe, minAlpha: 0.5, maxAlpha: 1.0, duration: 0.8)
            }
            pipe.addChild(stripe)
        }

        let capY = isTop ? -size.height / 2 + 12 : size.height / 2 - 12
        let cap = SKShapeNode(rectOf: CGSize(width: size.width + 8, height: 18), cornerRadius: 4)
        cap.fillColor = theme.metalMid
        cap.strokeColor = theme.accent
        cap.lineWidth = 2
        cap.position = CGPoint(x: 0, y: capY)
        cap.zPosition = 3
        pipe.addChild(cap)

        return pipe
    }

    private static func makeRooftopPipe(size: CGSize, isTop: Bool, theme: ThemePalette) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        attachPhysics(to: pipe, size: size)

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
