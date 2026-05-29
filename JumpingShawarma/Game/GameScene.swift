import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private var state: GameState = .ready
    private var isSetup = false
    private var bird: SKNode!
    private var ground: SKNode!

    private let level: LevelConfig
    private let scoreManager = ScoreManager()
    private let pipeSpawner = PipeSpawner()
    private var hud: GameHUD!
    private var safeAreaTop: CGFloat = 0

    var onNextLevel: ((LevelConfig) -> Void)?
    var onStateChange: ((GameState) -> Void)?

    init(size: CGSize, level: LevelConfig) {
        self.level = level
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: GameConstants.gravity)
        physicsWorld.contactDelegate = self
        configureIfNeeded()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if !isSetup {
            configureIfNeeded()
            return
        }
        guard size.width > 0, size.height > 0 else { return }

        GroundBuilder.reposition(ground, sceneWidth: size.width)
        hud.layout(for: size, safeAreaTop: safeAreaTop)
        if state == .ready {
            BirdNode.reset(bird, in: size)
        }
    }

    func applySafeArea(top: CGFloat) {
        safeAreaTop = top
        guard isSetup else { return }
        GroundBuilder.reposition(ground, sceneWidth: size.width)
        hud.layout(for: size, safeAreaTop: top)
        if state == .ready {
            BirdNode.reset(bird, in: size)
        }
    }

    private func configureIfNeeded() {
        guard !isSetup else { return }
        guard size.width > 0, size.height > 0 else { return }

        BackgroundBuilder.add(to: self)

        ground = GroundBuilder.make(in: size)
        addChild(ground)

        bird = BirdNode.make(at: CGPoint(
            x: size.width * GameConstants.birdStartXRatio,
            y: size.height * GameConstants.birdStartYRatio
        ))
        addChild(bird)

        hud = GameHUD(sceneSize: size)
        hud.add(to: self)

        isSetup = true
        enterReadyState()
    }

    // MARK: - State

    private func enterReadyState() {
        state = .ready
        onStateChange?(.ready)
        BirdNode.reset(bird, in: size)
        bird.isHidden = false
        scoreManager.reset()
        pipeSpawner.removeAll(from: self)
        pipeSpawner.resetTimer()
        hud.showReady(level: level)
    }

    private func startGame() {
        state = .playing
        onStateChange?(.playing)
        hud.showPlaying(level: level)
        BirdNode.startFlying(bird)
        pipeSpawner.resetTimer()
        BirdNode.flap(bird)
    }

    private func endGame() {
        guard state.isPlaying else { return }

        state = .gameOver
        onStateChange?(.gameOver)
        BirdNode.stop(bird)
        pipeSpawner.stopPipes(in: self)
        scoreManager.saveBestIfNeeded()
        hud.showGameOver(
            score: scoreManager.current,
            goal: level.ordersRequired,
            best: scoreManager.best
        )
    }

    private func beginVictorySequence() {
        guard state.isPlaying else { return }

        state = .victoryRun
        onStateChange?(.victoryRun)
        pipeSpawner.disableSpawning()
        pipeSpawner.exitRemainingObstacles(in: self)
        BirdNode.disableCollisions(bird)

        BirdNode.playVictoryExit(bird, in: size) { [weak self] in
            self?.completeLevel()
        }
    }

    private func completeLevel() {
        guard state == .victoryRun else { return }

        state = .levelComplete
        onStateChange?(.levelComplete)
        pipeSpawner.removeAll(from: self)
        scoreManager.saveBestIfNeeded()
        LevelProgress.markCompleted(level)
        hud.showLevelComplete(level: level)
    }

    // MARK: - Loop

    override func update(_ currentTime: TimeInterval) {
        guard state.isPlaying else { return }

        pipeSpawner.update(currentTime: currentTime, scene: self)
        BirdNode.updateRotation(bird)

        if bird.position.y > size.height + 40 || bird.position.y < -40 {
            endGame()
        }
    }

    // MARK: - Input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch state {
        case .ready:
            startGame()
        case .playing:
            BirdNode.flap(bird)
        case .victoryRun:
            break
        case .gameOver:
            enterReadyState()
        case .levelComplete:
            handleLevelCompleteTap(touches)
        }
    }

    private func handleLevelCompleteTap(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch hud.levelCompleteAction(at: location) {
        case .playAgain:
            enterReadyState()
        case .next:
            if let nextLevel = level.next {
                onNextLevel?(nextLevel)
            }
        case nil:
            break
        }
    }

    // MARK: - Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        guard state.isPlaying else { return }

        let masks = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if masks == PhysicsCategory.bird | PhysicsCategory.score {
            handleScoreContact(contact)
            return
        }

        if masks & PhysicsCategory.pipe != 0 || masks & PhysicsCategory.ground != 0 {
            endGame()
        }
    }

    private func handleScoreContact(_ contact: SKPhysicsContact) {
        let scoreNode = contact.bodyA.categoryBitMask == PhysicsCategory.score
            ? contact.bodyA.node
            : contact.bodyB.node
        guard let node = scoreNode, node.name == PipeNode.scoreZoneName else { return }
        node.name = PipeNode.scoredZoneName

        let score = scoreManager.increment()
        hud.updateScore(score, goal: level.ordersRequired)

        if score >= level.ordersRequired {
            beginVictorySequence()
        }
    }
}
