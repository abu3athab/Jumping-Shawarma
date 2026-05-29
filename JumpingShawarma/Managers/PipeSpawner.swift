import SpriteKit

final class PipeSpawner {
    private var lastSpawnTime: TimeInterval = 0
    private var canSpawn = true

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

        let topPipe = PipeNode.makePipe(size: CGSize(width: pipeWidth, height: topHeight), isTop: true)
        topPipe.position = CGPoint(x: size.width + pipeWidth, y: size.height - topHeight / 2)
        scene.addChild(topPipe)

        let bottomPipe = PipeNode.makePipe(size: CGSize(width: pipeWidth, height: bottomHeight), isTop: false)
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
