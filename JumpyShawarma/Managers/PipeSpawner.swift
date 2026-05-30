import SpriteKit

final class PipeSpawner {
    private enum GapZone: CaseIterable {
        case low
        case mid
        case high
    }

    private var lastSpawnTime: TimeInterval = 0
    private var lastGapZone: GapZone?
    private var canSpawn = true
    var theme: ThemePalette = .nightAlley
    var level: LevelConfig = .nightAlley

    func resetTimer() {
        lastSpawnTime = 0
        lastGapZone = nil
        canSpawn = true
    }

    func disableSpawning() {
        canSpawn = false
    }

    func stopPipes(in scene: SKScene) {
        enumerateObstacles(in: scene) { node in
            node.removeAllActions()
        }
    }

    var spawnTime: TimeInterval {
        lastSpawnTime
    }

    func restoreSpawnTime(_ time: TimeInterval) {
        lastSpawnTime = time
        canSpawn = true
    }

    func markSpawnFromNow(_ currentTime: TimeInterval) {
        lastSpawnTime = currentTime
        canSpawn = true
    }

    func scheduleNextSpawn(after delay: TimeInterval, from currentTime: TimeInterval) {
        lastSpawnTime = currentTime - GameConstants.pipeSpawnInterval + delay
        canSpawn = true
    }

    func scaleObstaclePositions(in scene: SKScene, scaleX: CGFloat, scaleY: CGFloat) {
        enumerateObstacles(in: scene) { node in
            node.removeAllActions()
            node.position = CGPoint(
                x: node.position.x * scaleX,
                y: node.position.y * scaleY
            )
        }
    }

    func resumeScroll(in scene: SKScene) {
        let scrollSpeed = GameConstants.pipeSpeed
        var nodesByPairX: [Int: [SKNode]] = [:]

        enumerateObstacles(in: scene) { node in
            let remainingDistance = node.position.x + self.level.pipeWidth * 2
            guard remainingDistance > 0 else {
                node.removeFromParent()
                return
            }

            let key = self.pairKey(for: node)
            nodesByPairX[key, default: []].append(node)
        }

        for (_, nodes) in nodesByPairX {
            guard let anchor = nodes.first else { continue }

            let anchorX = pairAnchorX(for: anchor)
            let remainingDistance = anchorX + level.pipeWidth * 2
            let duration = TimeInterval(remainingDistance / scrollSpeed)
            let phaseDelay = level.hasMovingObstacles
                ? TimeInterval.random(in: 0...(level.obstacleVerticalDuration * 2))
                : 0
            let movement = pairMovementActions(
                horizontalDuration: duration,
                removesFromParent: true,
                phaseDelay: phaseDelay
            )

            for node in nodes {
                node.removeAllActions()
                node.run(movement.copy() as! SKAction)
            }
        }
    }

    func prepareContinue(in scene: SKScene) -> CGPoint {
        let size = scene.size
        let spawnX = size.width * GameConstants.birdStartXRatio
        let minY = GameConstants.groundHeight + 60
        let maxY = size.height * 0.68
        let defaultY = size.height * GameConstants.birdStartYRatio

        clearObstaclesBlockingSpawn(at: spawnX, in: scene)

        if let nextGap = nearestGapAhead(of: spawnX, in: scene) {
            let y = min(max(nextGap.y, minY), maxY)
            return CGPoint(x: spawnX, y: y)
        }

        return CGPoint(x: spawnX, y: min(max(defaultY, minY), maxY))
    }

    private func nearestGapAhead(of spawnX: CGFloat, in scene: SKScene) -> CGPoint? {
        var bestZone: SKNode?
        var bestX = CGFloat.greatestFiniteMagnitude

        for name in [PipeNode.scoreZoneName, PipeNode.scoredZoneName] {
            scene.enumerateChildNodes(withName: name) { node, _ in
                guard node.position.x > spawnX + self.level.pipeWidth else { return }
                guard node.position.x < bestX else { return }
                bestX = node.position.x
                bestZone = node
            }
        }

        guard let zone = bestZone else { return nil }
        return zone.position
    }

    private func clearObstaclesBlockingSpawn(at spawnX: CGFloat, in scene: SKScene) {
        let clearance = GameConstants.continueSpawnClearance
        var pairCenters = Set<Int>()

        enumerateObstacles(in: scene) { node in
            if abs(node.position.x - spawnX) <= clearance {
                pairCenters.insert(Int(node.position.x.rounded()))
            }
        }

        for center in pairCenters {
            removeObstaclePair(nearX: CGFloat(center), in: scene)
        }
    }

    private func removeObstaclePair(nearX x: CGFloat, in scene: SKScene) {
        let tolerance = level.pipeWidth + 24

        enumerateObstacles(in: scene) { node in
            guard abs(node.position.x - x) <= tolerance else { return }
            node.removeAllActions()
            node.removeFromParent()
        }
    }

    func safeContinuePosition(in scene: SKScene) -> CGPoint {
        prepareContinue(in: scene)
    }

    func removeAll(from scene: SKScene) {
        lastGapZone = nil
        enumerateObstacles(in: scene) { node in
            node.removeFromParent()
        }
    }

    func exitRemainingObstacles(in scene: SKScene) {
        enumerateObstacles(in: scene) { node in
            node.removeAllActions()
            node.run(.sequence([
                SKAction.group([
                    SKAction.moveBy(x: -scene.size.width - 80, y: 0, duration: GameConstants.obstacleExitDuration),
                    SKAction.fadeOut(withDuration: GameConstants.obstacleExitDuration),
                ]),
                SKAction.removeFromParent(),
            ]))
        }
    }

    func update(currentTime: TimeInterval, scene: SKScene) {
        guard canSpawn else { return }
        if lastSpawnTime == 0 {
            lastSpawnTime = currentTime
        }
        guard currentTime - lastSpawnTime >= GameConstants.pipeSpawnInterval else { return }
        spawnPair(in: scene)
        lastSpawnTime = currentTime
    }

    private func spawnPair(in scene: SKScene) {
        let size = scene.size
        let pipeWidth = level.pipeWidth
        let gapHeight = GameConstants.gapHeight
        let bounds = gapCenterBounds(in: size)
        let centerY = pickGapCenterY(minY: bounds.minY, maxY: bounds.maxY)

        let topHeight = size.height - (centerY + gapHeight / 2)
        let bottomHeight = centerY - gapHeight / 2

        let topPipe = PipeNode.makePipe(size: CGSize(width: pipeWidth, height: topHeight), isTop: true, theme: theme)
        topPipe.position = CGPoint(x: size.width + pipeWidth, y: size.height - topHeight / 2)
        scene.addChild(topPipe)

        let bottomPipe = PipeNode.makePipe(size: CGSize(width: pipeWidth, height: bottomHeight), isTop: false, theme: theme)
        bottomPipe.position = CGPoint(x: size.width + pipeWidth, y: bottomHeight / 2)
        scene.addChild(bottomPipe)

        let scoreZone = PipeNode.makeScoreZone(
            at: CGPoint(x: size.width + pipeWidth + 10, y: centerY),
            gapHeight: gapHeight
        )
        scene.addChild(scoreZone)

        let distance = size.width + pipeWidth * 2
        let duration = distance / GameConstants.pipeSpeed
        let phaseDelay = level.hasMovingObstacles
            ? TimeInterval.random(in: 0...(level.obstacleVerticalDuration * 2))
            : 0
        let movement = pairMovementActions(
            horizontalDuration: duration,
            removesFromParent: true,
            phaseDelay: phaseDelay
        )

        topPipe.run(movement.copy() as! SKAction)
        bottomPipe.run(movement.copy() as! SKAction)
        scoreZone.run(movement.copy() as! SKAction)
    }

    private func gapCenterBounds(in size: CGSize) -> (minY: CGFloat, maxY: CGFloat) {
        let gapHalf = GameConstants.gapHeight / 2
        let amplitude = level.hasMovingObstacles ? level.obstacleVerticalAmplitude : 0
        let edgeMargin: CGFloat = 120 + amplitude * 0.35
        let maxY = size.height - edgeMargin - gapHalf - amplitude
        let minY = max(
            GameConstants.groundHeight + gapHalf + amplitude + 28,
            edgeMargin + gapHalf + amplitude * 0.5
        )
        return (minY, max(minY, maxY))
    }

    private func pickGapCenterY(minY: CGFloat, maxY: CGFloat) -> CGFloat {
        let span = maxY - minY
        guard span > 1 else { return (minY + maxY) / 2 }

        let zoneSpan = span / 3
        var zones = GapZone.allCases
        if let lastGapZone, zones.count > 1 {
            zones.removeAll { $0 == lastGapZone }
        }

        let zone = zones.randomElement() ?? .mid
        lastGapZone = zone

        let zoneRange: ClosedRange<CGFloat>
        switch zone {
        case .low:
            zoneRange = minY...(minY + zoneSpan)
        case .mid:
            zoneRange = (minY + zoneSpan)...(minY + zoneSpan * 2)
        case .high:
            zoneRange = (minY + zoneSpan * 2)...maxY
        }

        return CGFloat.random(in: zoneRange)
    }

    private func pairMovementActions(
        horizontalDuration: TimeInterval,
        removesFromParent: Bool,
        phaseDelay: TimeInterval = 0
    ) -> SKAction {
        let distance = horizontalDuration * GameConstants.pipeSpeed
        let scrollAction: SKAction
        if removesFromParent {
            scrollAction = SKAction.sequence([
                SKAction.moveBy(x: -distance, y: 0, duration: horizontalDuration),
                SKAction.removeFromParent(),
            ])
        } else {
            scrollAction = SKAction.moveBy(x: -distance, y: 0, duration: horizontalDuration)
        }

        guard level.hasMovingObstacles else { return scrollAction }

        let amplitude = level.obstacleVerticalAmplitude
        let halfCycle = level.obstacleVerticalDuration
        let delay = phaseDelay > 0
            ? phaseDelay
            : TimeInterval.random(in: 0...(halfCycle * 2))

        let oscillate = SKAction.repeatForever(.sequence([
            SKAction.moveBy(x: 0, y: amplitude, duration: halfCycle),
            SKAction.moveBy(x: 0, y: -amplitude, duration: halfCycle),
        ]))

        let vertical = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            oscillate,
        ])

        return SKAction.group([scrollAction, vertical])
    }

    private func enumerateObstacles(in scene: SKScene, body: @escaping (SKNode) -> Void) {
        for name in [PipeNode.pipeName, PipeNode.scoreZoneName, PipeNode.scoredZoneName] {
            scene.enumerateChildNodes(withName: name) { node, _ in
                body(node)
            }
        }
    }

    private func pairAnchorX(for node: SKNode) -> CGFloat {
        if node.name == PipeNode.scoreZoneName || node.name == PipeNode.scoredZoneName {
            return node.position.x - 10
        }
        return node.position.x
    }

    private func pairKey(for node: SKNode) -> Int {
        Int(pairAnchorX(for: node).rounded())
    }
}
