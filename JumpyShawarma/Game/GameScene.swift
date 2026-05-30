import AVFoundation
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
    private var continueSnapshot: RunSnapshot?
    private var hasUsedContinue = false
    private var isInvincible = false
    private var lastUpdateTime: TimeInterval = 0

    private static let gameOverSound = SKAction.playSoundFileNamed("gameOverSound.caf", waitForCompletion: false)

    var onNextLevel: ((LevelConfig) -> Void)?
    var onStateChange: ((GameState) -> Void)?
    var onWatchAdToContinue: ((@escaping (Bool) -> Void) -> Void)?

    init(size: CGSize, level: LevelConfig) {
        self.level = level
        super.init(size: size)
        backgroundColor = level.theme.background
        configureIfNeeded()
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

        switch state {
        case .ready:
            BirdNode.reset(bird, in: size)
        case .playing, .gameOver, .continueCountdown:
            if oldSize.width > 0, oldSize.height > 0, oldSize != size {
                reflowWorldPositions(from: oldSize, to: size)
            }
        default:
            break
        }
    }

    func applySafeArea(top: CGFloat) {
        safeAreaTop = top
        guard isSetup else { return }
        guard state == .ready else {
            hud.layout(for: size, safeAreaTop: top)
            return
        }
        GroundBuilder.reposition(ground, sceneWidth: size.width)
        hud.layout(for: size, safeAreaTop: top)
        BirdNode.reset(bird, in: size)
    }

    private func reflowWorldPositions(from oldSize: CGSize, to newSize: CGSize) {
        guard oldSize.width > 0, oldSize.height > 0 else { return }

        let scaleX = newSize.width / oldSize.width
        let scaleY = newSize.height / oldSize.height

        bird.position = CGPoint(
            x: bird.position.x * scaleX,
            y: bird.position.y * scaleY
        )
        pipeSpawner.scaleObstaclePositions(in: self, scaleX: scaleX, scaleY: scaleY)
        if state == .playing {
            pipeSpawner.resumeScroll(in: self)
        }
        GroundBuilder.reposition(ground, sceneWidth: newSize.width)
    }

    private func scaledPoint(_ point: CGPoint, from oldSize: CGSize, to newSize: CGSize) -> CGPoint {
        CGPoint(
            x: point.x * newSize.width / oldSize.width,
            y: point.y * newSize.height / oldSize.height
        )
    }

    private func clearContinueInvincibility() {
        removeAction(forKey: "continueInvincibility")
        isInvincible = false
        BirdNode.restoreCollisions(bird)
    }

    private func configureIfNeeded() {
        guard !isSetup else { return }
        guard size.width > 0, size.height > 0 else { return }

        BackgroundBuilder.add(to: self, theme: level.theme)

        ground = GroundBuilder.make(in: size, theme: level.theme)
        addChild(ground)

        bird = BirdNode.make(at: CGPoint(
            x: size.width * GameConstants.birdStartXRatio,
            y: size.height * GameConstants.birdStartYRatio
        ))
        addChild(bird)
        BirdNode.preloadSounds()

        pipeSpawner.theme = level.theme
        pipeSpawner.level = level
        hud = GameHUD(sceneSize: size, theme: level.theme)
        hud.add(to: self)

        isSetup = true
        primeAudioEngine()
        enterReadyState()
    }

    /// Starts the scene's audio engine up front so the first flap plays the
    /// jump sound instantly instead of paying a cold-start freeze mid-tap.
    private func primeAudioEngine() {
        _ = Self.gameOverSound
        guard !audioEngine.isRunning else { return }
        try? audioEngine.start()
    }

    // MARK: - State

    private func enterReadyState() {
        state = .ready
        onStateChange?(.ready)
        clearContinueInvincibility()
        continueSnapshot = nil
        hasUsedContinue = false
        BirdNode.reset(bird, in: size)
        bird.isHidden = false
        scoreManager.reset()
        pipeSpawner.removeAll(from: self)
        pipeSpawner.resetTimer()
        hud.showReady(level: level)
    }

    private func retryRun() {
        enterReadyState()
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

        continueSnapshot = RunSnapshot(
            score: scoreManager.current,
            birdPosition: bird.position,
            birdRotation: bird.zRotation,
            lastSpawnTime: pipeSpawner.spawnTime,
            sceneSize: size
        )

        state = .gameOver
        onStateChange?(.gameOver)
        run(Self.gameOverSound)
        BirdNode.stop(bird)
        pipeSpawner.stopPipes(in: self)
        scoreManager.saveBestIfNeeded()
        hud.showGameOver(
            score: scoreManager.current,
            goal: level.ordersRequired,
            best: scoreManager.best,
            canContinue: !hasUsedContinue
        )
    }

    private func beginContinueAfterAd() {
        guard state == .gameOver, continueSnapshot != nil else { return }

        if continueSnapshot?.sceneSize != size {
            reflowWorldPositions(from: continueSnapshot!.sceneSize, to: size)
        }

        let safePosition = pipeSpawner.prepareContinue(in: self)
        bird.position = safePosition
        bird.zRotation = 0
        bird.zPosition = 15
        BirdNode.stop(bird)

        state = .continueCountdown
        onStateChange?(.continueCountdown)

        hud.showContinueCountdown { [weak self] in
            self?.resumeAfterContinue()
        }
    }

    func resumeAfterContinue() {
        guard let snapshot = continueSnapshot else { return }
        guard state == .continueCountdown else { return }

        clearContinueInvincibility()

        if snapshot.sceneSize != size {
            reflowWorldPositions(from: snapshot.sceneSize, to: size)
        }

        state = .playing
        onStateChange?(.playing)
        hasUsedContinue = true
        isInvincible = true

        scoreManager.restoreCurrent(snapshot.score)
        BirdNode.resume(bird, at: bird.position)
        pipeSpawner.scheduleNextSpawn(after: 1.4, from: lastUpdateTime)
        pipeSpawner.resumeScroll(in: self)

        hud.showPlaying(score: snapshot.score, goal: level.ordersRequired)
        continueSnapshot = nil

        run(.sequence([
            .wait(forDuration: GameConstants.continueInvincibilityDuration),
            .run { [weak self] in
                self?.clearContinueInvincibility()
            },
        ]), withKey: "continueInvincibility")
    }

    private func requestContinueWithAd() {
        guard continueSnapshot != nil, !hasUsedContinue else { return }

        onWatchAdToContinue? { [weak self] rewarded in
            guard let self, rewarded else { return }
            self.beginContinueAfterAd()
        }
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
        lastUpdateTime = currentTime
        guard state.isPlaying else { return }

        pipeSpawner.update(currentTime: currentTime, scene: self)
        BirdNode.updateRotation(bird)

        if !isInvincible && (bird.position.y > size.height + 40 || bird.position.y < -40) {
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
            handleGameOverTap(touches)
        case .continueCountdown:
            break
        case .levelComplete:
            handleLevelCompleteTap(touches)
        }
    }

    private func handleGameOverTap(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch hud.gameOverAction(at: location) {
        case .watchAd:
            UISounds.playButtonTap()
            requestContinueWithAd()
        case .retry:
            UISounds.playButtonTap()
            retryRun()
        case nil:
            break
        }
    }

    private func handleLevelCompleteTap(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch hud.levelCompleteAction(at: location) {
        case .playAgain:
            UISounds.playButtonTap()
            enterReadyState()
        case .next:
            UISounds.playButtonTap()
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
            guard !isInvincible else { return }
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
