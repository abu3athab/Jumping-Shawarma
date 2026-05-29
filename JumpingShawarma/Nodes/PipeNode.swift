import SpriteKit

enum PipeNode {
    static let pipeName = "pipe"
    static let scoreZoneName = "scoreZone"
    static let scoredZoneName = "scored"

    static func makePipe(size: CGSize, isTop: Bool) -> SKSpriteNode {
        let pipe = SKSpriteNode(color: .clear, size: size)
        pipe.name = pipeName
        pipe.zPosition = 3
        pipe.physicsBody = SKPhysicsBody(rectangleOf: size)
        pipe.physicsBody?.isDynamic = false
        pipe.physicsBody?.categoryBitMask = PhysicsCategory.pipe
        pipe.physicsBody?.contactTestBitMask = PhysicsCategory.bird

        let frame = SKShapeNode(rectOf: CGSize(width: size.width - 6, height: size.height - 4), cornerRadius: 8)
        frame.fillColor = GameTheme.metalDark
        frame.strokeColor = GameTheme.metalLight.withAlphaComponent(0.45)
        frame.lineWidth = 2
        pipe.addChild(frame)

        addGrillBars(to: pipe, size: size)
        addHeatBands(to: pipe, size: size)

        let capY = isTop ? -size.height / 2 + 16 : size.height / 2 - 16
        let cap = SKShapeNode(rectOf: CGSize(width: size.width + 10, height: 24), cornerRadius: 6)
        cap.fillColor = GameTheme.metalMid
        cap.strokeColor = GameTheme.ember.withAlphaComponent(0.8)
        cap.lineWidth = 2
        cap.position = CGPoint(x: 0, y: capY)
        cap.zPosition = 2
        pipe.addChild(cap)

        let flame = SKShapeNode(circleOfRadius: 7)
        flame.fillColor = GameTheme.ember
        flame.strokeColor = GameTheme.gold.withAlphaComponent(0.6)
        flame.lineWidth = 1
        flame.position = CGPoint(x: 0, y: capY + (isTop ? -18 : 18))
        flame.zPosition = 3
        GameTheme.pulse(node: flame, minAlpha: 0.65, maxAlpha: 1.0, duration: 0.35)
        pipe.addChild(flame)

        return pipe
    }

    private static func addGrillBars(to pipe: SKSpriteNode, size: CGSize) {
        let spacing: CGFloat = 34
        let barCount = max(1, Int(size.height / spacing))
        for index in 0..<barCount {
            let y = -size.height / 2 + 24 + CGFloat(index) * spacing
            let bar = SKShapeNode(rectOf: CGSize(width: size.width - 14, height: 4), cornerRadius: 2)
            bar.fillColor = GameTheme.metalLight.withAlphaComponent(0.55)
            bar.strokeColor = .clear
            bar.position = CGPoint(x: 0, y: y)
            bar.zPosition = 1
            pipe.addChild(bar)
        }
    }

    private static func addHeatBands(to pipe: SKSpriteNode, size: CGSize) {
        let spacing: CGFloat = 56
        let bandCount = max(1, Int(size.height / spacing))
        for index in 0..<bandCount {
            let y = -size.height / 2 + 40 + CGFloat(index) * spacing
            let band = SKShapeNode(rectOf: CGSize(width: size.width - 10, height: 8), cornerRadius: 4)
            band.fillColor = GameTheme.emberGlow
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: y)
            band.zPosition = 1
            GameTheme.pulse(node: band, minAlpha: 0.25, maxAlpha: 0.7, duration: 0.8 + Double(index) * 0.05)
            pipe.addChild(band)
        }
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
