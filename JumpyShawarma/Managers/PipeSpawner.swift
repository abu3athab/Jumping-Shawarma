import SpriteKit

final class PipeSpawner {
    private var lastSpawnTime: TimeInterval = 0
    private var canSpawn = true
    var theme: ThemePalette = .nightAlley

    func resetTimer() {
        lastSpawnTime = 0
        canSpawn = true
    }

    func disableSpawning() {
        canSpawn = false
    }

    func stopPipes(in scene: SKScene) {
        scene.enumerateChildNodes(withName: PipeNode.pipeName) { node, _ in
            node.removeAllActions()
        }
        scene.enumerateChildNodes(withName: PipeNode.scoreZoneName) { node, _ in
            node.removeAllActions()
        }
        scene.enumerateChildNodes(withName: PipeNode.scoredZoneName) { node, _ in
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
        let names = [PipeNode.pipeName, PipeNode.scoreZoneName, PipeNode.scoredZoneName]
        for name in names {
            scene.enumerateChildNodes(withName: name) { node, _ in
                node.removeAllActions()
                node.position = CGPoint(
                    x: node.position.x * scaleX,
                    y: node.position.y * scaleY
                )
            }
        }
    }

    func resumeScroll(in scene: SKScene) {
        let scrollSpeed = GameConstants.pipeSpeed
        let names = [PipeNode.pipeName, PipeNode.scoreZoneName, PipeNode.scoredZoneName]

        for name in names {
            scene.enumerateChildNodes(withName: name) { node, _ in
                node.removeAllActions()
                let remainingDistance = node.position.x + GameConstants.pipeWidth * 2
                guard remainingDistance > 0 else {
                    node.removeFromParent()
                    return
                }

                let duration = TimeInterval(remainingDistance / scrollSpeed)
                node.run(.sequence([
                    SKAction.moveBy(x: -remainingDistance, y: 0, duration: duration),
                    SKAction.removeFromParent(),
                ]))
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
                guard node.position.x > spawnX + GameConstants.pipeWidth else { return }
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

        scene.enumerateChildNodes(withName: PipeNode.pipeName) { node, _ in
            if abs(node.position.x - spawnX) <= clearance {
                pairCenters.insert(Int(node.position.x.rounded()))
            }
        }

        scene.enumerateChildNodes(withName: PipeNode.scoreZoneName) { node, _ in
            if abs(node.position.x - spawnX) <= clearance {
                pairCenters.insert(Int(node.position.x.rounded()))
            }
        }

        scene.enumerateChildNodes(withName: PipeNode.scoredZoneName) { node, _ in
            if abs(node.position.x - spawnX) <= clearance {
                pairCenters.insert(Int(node.position.x.rounded()))
            }
        }

        for center in pairCenters {
            removeObstaclePair(nearX: CGFloat(center), in: scene)
        }
    }

    private func removeObstaclePair(nearX x: CGFloat, in scene: SKScene) {
        let tolerance = GameConstants.pipeWidth + 24
        let names = [PipeNode.pipeName, PipeNode.scoreZoneName, PipeNode.scoredZoneName]

        for name in names {
            scene.enumerateChildNodes(withName: name) { node, _ in
                guard abs(node.position.x - x) <= tolerance else { return }
                node.removeAllActions()
                node.removeFromParent()
            }
        }
    }

    func safeContinuePosition(in scene: SKScene) -> CGPoint {
        prepareContinue(in: scene)
    }

    func removeAll(from scene: SKScene) {
        scene.enumerateChildNodes(withName: PipeNode.pipeName) { node, _ in
            node.removeFromParent()
        }
        scene.enumerateChildNodes(withName: PipeNode.scoreZoneName) { node, _ in
            node.removeFromParent()
        }
        scene.enumerateChildNodes(withName: PipeNode.scoredZoneName) { node, _ in
            node.removeFromParent()
        }
    }

    func exitRemainingObstacles(in scene: SKScene) {
        let names = [PipeNode.pipeName, PipeNode.scoreZoneName, PipeNode.scoredZoneName]
        for name in names {
            scene.enumerateChildNodes(withName: name) { node, _ in
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
        let pipeWidth = GameConstants.pipeWidth
        let gapHeight = GameConstants.gapHeight
        let minMargin: CGFloat = 120
        let maxY = size.height - minMargin - gapHeight / 2
        let minY = minMargin + gapHeight / 2 + 80
        let centerY = CGFloat.random(in: minY...maxY)

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
        let scroll = SKAction.sequence([
            SKAction.moveBy(x: -distance, y: 0, duration: duration),
            SKAction.removeFromParent(),
        ])

        topPipe.run(scroll)
        bottomPipe.run(scroll)
        scoreZone.run(scroll)
    }
}
