import SpriteKit

enum LevelCompleteAction {
    case next
    case playAgain
}

enum GameOverAction {
    case watchAd
    case retry
}

final class GameHUD {
    static let nextButtonName = "levelCompleteNext"
    static let playAgainButtonName = "levelCompletePlayAgain"
    static let watchAdButtonName = "gameOverWatchAd"
    static let retryButtonName = "gameOverRetry"

    let scoreLabel: SKLabelNode
    let scoreCaptionLabel: SKLabelNode
    let messageLabel: SKLabelNode
    let subMessageLabel: SKLabelNode

    private let scoreBadge: SKShapeNode
    private let completeOverlay: SKShapeNode
    private let completePanel: SKShapeNode
    private let completeIcon: SKShapeNode
    private let completeTitleLabel: SKLabelNode
    private let completeMessageLabel: SKLabelNode
    private let completeSubLabel: SKLabelNode
    private let completeNextButton: SKNode
    private let completePlayAgainButton: SKNode
    private let gameOverOverlay: SKShapeNode
    private let gameOverPanel: SKShapeNode
    private let gameOverTitleLabel: SKLabelNode
    private let gameOverSubLabel: SKLabelNode
    private let gameOverWatchAdButton: SKNode
    private let gameOverRetryButton: SKNode
    private let countdownOverlay: SKShapeNode
    private let countdownLabel: SKLabelNode
    private let countdownCaptionLabel: SKLabelNode

    private var isNextLevelEnabled = false
    private var canWatchAdToContinue = false
    private var panelCenter = CGPoint.zero
    private let theme: ThemePalette

    private enum GameOverLayout {
        static let panelSize = CGSize(width: 300, height: 252)
        static let titleY: CGFloat = 64
        static let subtitleY: CGFloat = 28
        static let buttonsY: CGFloat = -58
        static let buttonSpacing: CGFloat = 72
        static let singleButtonY: CGFloat = -58
    }

    init(sceneSize: CGSize, theme: ThemePalette) {
        self.theme = theme

        scoreBadge = SKShapeNode(rectOf: GameHUDLayout.scoreBadgeSize, cornerRadius: 14)
        scoreBadge.fillColor = GameTheme.color(0.1, 0.07, 0.06, 0.72)
        scoreBadge.strokeColor = theme.accent.withAlphaComponent(0.55)
        scoreBadge.lineWidth = 2
        scoreBadge.zPosition = 19

        scoreCaptionLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        scoreCaptionLabel.fontSize = 13
        scoreCaptionLabel.fontColor = theme.textPrimary.withAlphaComponent(0.85)
        scoreCaptionLabel.verticalAlignmentMode = .center
        scoreCaptionLabel.zPosition = 20

        scoreLabel = SKLabelNode(fontNamed: GameTheme.scoreFont)
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = theme.accent
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 20
        scoreLabel.text = "0"

        messageLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        messageLabel.fontSize = 30
        messageLabel.fontColor = theme.textPrimary
        messageLabel.zPosition = 20

        subMessageLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        subMessageLabel.fontSize = 17
        subMessageLabel.fontColor = theme.accent.withAlphaComponent(0.95)
        subMessageLabel.zPosition = 20

        completeOverlay = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        completeOverlay.fillColor = GameTheme.color(0.05, 0.03, 0.02, 0.62)
        completeOverlay.strokeColor = .clear
        completeOverlay.zPosition = 30
        completeOverlay.isHidden = true

        completePanel = SKShapeNode(rectOf: CGSize(width: 300, height: 280), cornerRadius: 22)
        completePanel.fillColor = GameTheme.color(0.12, 0.08, 0.06, 0.94)
        completePanel.strokeColor = theme.accent
        completePanel.lineWidth = 3
        completePanel.zPosition = 31
        completePanel.isHidden = true

        completeIcon = SKShapeNode(circleOfRadius: 28)
        completeIcon.fillColor = theme.accent.withAlphaComponent(0.18)
        completeIcon.strokeColor = theme.accent
        completeIcon.lineWidth = 3
        completeIcon.zPosition = 32
        completeIcon.isHidden = true

        let checkmark = SKLabelNode(fontNamed: GameTheme.titleFont)
        checkmark.text = "✓"
        checkmark.fontSize = 34
        checkmark.fontColor = theme.accent
        checkmark.verticalAlignmentMode = .center
        checkmark.horizontalAlignmentMode = .center
        checkmark.position = .zero
        checkmark.zPosition = 1
        completeIcon.addChild(checkmark)

        completeTitleLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        completeTitleLabel.fontSize = 28
        completeTitleLabel.fontColor = theme.accent
        completeTitleLabel.text = "Level Complete!"
        completeTitleLabel.zPosition = 32
        completeTitleLabel.isHidden = true

        completeMessageLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        completeMessageLabel.fontSize = 20
        completeMessageLabel.fontColor = theme.textPrimary
        completeMessageLabel.zPosition = 32
        completeMessageLabel.isHidden = true

        completeSubLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        completeSubLabel.fontSize = 16
        completeSubLabel.fontColor = theme.accent.withAlphaComponent(0.9)
        completeSubLabel.zPosition = 32
        completeSubLabel.isHidden = true

        completePlayAgainButton = Self.makeButton(
            title: "Play Again",
            name: Self.playAgainButtonName,
            enabled: true,
            theme: theme
        )
        completeNextButton = Self.makeButton(
            title: "Next",
            name: Self.nextButtonName,
            enabled: true,
            theme: theme
        )
        completePlayAgainButton.isHidden = true
        completeNextButton.isHidden = true

        gameOverOverlay = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        gameOverOverlay.fillColor = GameTheme.color(0.05, 0.03, 0.02, 0.62)
        gameOverOverlay.strokeColor = .clear
        gameOverOverlay.zPosition = 30
        gameOverOverlay.isHidden = true

        gameOverPanel = SKShapeNode(rectOf: GameOverLayout.panelSize, cornerRadius: 22)
        gameOverPanel.fillColor = GameTheme.color(0.12, 0.08, 0.06, 0.94)
        gameOverPanel.strokeColor = theme.accent
        gameOverPanel.lineWidth = 3
        gameOverPanel.zPosition = 31
        gameOverPanel.isHidden = true

        gameOverTitleLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        gameOverTitleLabel.fontSize = 26
        gameOverTitleLabel.fontColor = theme.textPrimary
        gameOverTitleLabel.text = "Shawarma dropped!"
        gameOverTitleLabel.verticalAlignmentMode = .center
        gameOverTitleLabel.horizontalAlignmentMode = .center
        gameOverTitleLabel.zPosition = 32
        gameOverTitleLabel.isHidden = true

        gameOverSubLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        gameOverSubLabel.fontSize = 15
        gameOverSubLabel.fontColor = theme.accent.withAlphaComponent(0.9)
        gameOverSubLabel.verticalAlignmentMode = .center
        gameOverSubLabel.horizontalAlignmentMode = .center
        gameOverSubLabel.zPosition = 32
        gameOverSubLabel.isHidden = true

        gameOverWatchAdButton = Self.makeButton(
            title: "Keep Cooking",
            name: Self.watchAdButtonName,
            enabled: true,
            theme: theme,
            width: 128
        )
        gameOverRetryButton = Self.makeButton(
            title: "Retry",
            name: Self.retryButtonName,
            enabled: true,
            theme: theme,
            width: 108,
            style: .secondary
        )
        gameOverWatchAdButton.isHidden = true
        gameOverRetryButton.isHidden = true

        countdownOverlay = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        countdownOverlay.fillColor = GameTheme.color(0.05, 0.03, 0.02, 0.45)
        countdownOverlay.strokeColor = .clear
        countdownOverlay.zPosition = 34
        countdownOverlay.isHidden = true

        countdownLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        countdownLabel.fontSize = 84
        countdownLabel.fontColor = theme.accent
        countdownLabel.verticalAlignmentMode = .center
        countdownLabel.horizontalAlignmentMode = .center
        countdownLabel.zPosition = 35
        countdownLabel.isHidden = true

        countdownCaptionLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        countdownCaptionLabel.fontSize = 22
        countdownCaptionLabel.fontColor = theme.textPrimary
        countdownCaptionLabel.verticalAlignmentMode = .center
        countdownCaptionLabel.horizontalAlignmentMode = .center
        countdownCaptionLabel.zPosition = 35
        countdownCaptionLabel.isHidden = true

        GameTheme.attachShadow(to: scoreLabel)
        GameTheme.attachShadow(to: messageLabel)
        GameTheme.attachShadow(to: completeTitleLabel)
        GameTheme.attachShadow(to: completeMessageLabel)
        GameTheme.attachShadow(to: completeSubLabel)

        layout(for: sceneSize)
    }

    func add(to scene: SKScene) {
        scene.addChild(scoreBadge)
        scene.addChild(scoreCaptionLabel)
        scene.addChild(scoreLabel)
        scene.addChild(messageLabel)
        scene.addChild(subMessageLabel)
        scene.addChild(completeOverlay)
        scene.addChild(completePanel)
        scene.addChild(completeIcon)
        scene.addChild(completeTitleLabel)
        scene.addChild(completeMessageLabel)
        scene.addChild(completeSubLabel)
        scene.addChild(completePlayAgainButton)
        scene.addChild(completeNextButton)
        scene.addChild(gameOverOverlay)
        scene.addChild(gameOverPanel)
        scene.addChild(gameOverTitleLabel)
        scene.addChild(gameOverSubLabel)
        scene.addChild(gameOverWatchAdButton)
        scene.addChild(gameOverRetryButton)
        scene.addChild(countdownOverlay)
        scene.addChild(countdownCaptionLabel)
        scene.addChild(countdownLabel)
    }

    func layout(for sceneSize: CGSize, safeAreaTop: CGFloat = 0) {
        let badgeCenterY = GameHUDLayout.badgeCenterY(
            sceneHeight: sceneSize.height,
            safeAreaTop: safeAreaTop
        )

        scoreBadge.position = CGPoint(x: sceneSize.width / 2, y: badgeCenterY)
        scoreCaptionLabel.position = CGPoint(
            x: sceneSize.width / 2,
            y: badgeCenterY + GameHUDLayout.captionOffsetFromBadgeCenter
        )
        scoreLabel.position = CGPoint(
            x: sceneSize.width / 2,
            y: badgeCenterY - GameHUDLayout.scoreOffsetFromBadgeCenter
        )
        messageLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.62)
        subMessageLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.52)

        panelCenter = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.5)
        completePanel.position = panelCenter
        completeIcon.position = CGPoint(x: panelCenter.x, y: panelCenter.y + 82)
        completeTitleLabel.position = CGPoint(x: panelCenter.x, y: panelCenter.y + 28)
        completeMessageLabel.position = CGPoint(x: panelCenter.x, y: panelCenter.y - 4)
        completeSubLabel.position = CGPoint(x: panelCenter.x, y: panelCenter.y - 34)
        completePlayAgainButton.position = CGPoint(x: panelCenter.x - 72, y: panelCenter.y - 88)
        completeNextButton.position = CGPoint(x: panelCenter.x + 72, y: panelCenter.y - 88)

        gameOverPanel.position = panelCenter
        layoutGameOverContent(canContinue: canWatchAdToContinue)

        completeOverlay.path = CGPath(
            rect: CGRect(
                x: -sceneSize.width / 2,
                y: -sceneSize.height / 2,
                width: sceneSize.width,
                height: sceneSize.height
            ),
            transform: nil
        )
        completeOverlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)

        gameOverOverlay.path = CGPath(
            rect: CGRect(
                x: -sceneSize.width / 2,
                y: -sceneSize.height / 2,
                width: sceneSize.width,
                height: sceneSize.height
            ),
            transform: nil
        )
        gameOverOverlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)

        countdownOverlay.path = gameOverOverlay.path
        countdownOverlay.position = gameOverOverlay.position
        countdownLabel.position = panelCenter
        countdownCaptionLabel.position = CGPoint(x: panelCenter.x, y: panelCenter.y + 72)
    }

    func showReady(level: LevelConfig) {
        hideGameOver()
        hideLevelComplete()
        scoreCaptionLabel.text = "LEVEL \(level.id) · ORDERS"
        updateScore(0, goal: level.ordersRequired)
        messageLabel.text = level.name
        subMessageLabel.text = level.readySubtitle
        GameTheme.syncShadow(on: messageLabel)
        scoreBadge.alpha = 0.55
    }

    func showPlaying(level: LevelConfig) {
        hideGameOver()
        hideLevelComplete()
        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        scoreBadge.alpha = 1.0
        updateScore(0, goal: level.ordersRequired)
    }

    func showPlaying(score: Int, goal: Int) {
        hideGameOver()
        hideLevelComplete()
        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        scoreBadge.alpha = 1.0
        updateScore(score, goal: goal)
    }

    func showGameOver(score: Int, goal: Int, best: Int, canContinue: Bool) {
        hideLevelComplete()
        canWatchAdToContinue = canContinue

        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        scoreBadge.alpha = 0.75
        updateScore(score, goal: goal)

        gameOverOverlay.isHidden = false
        gameOverPanel.isHidden = false
        gameOverTitleLabel.isHidden = false
        gameOverSubLabel.isHidden = false
        gameOverRetryButton.isHidden = false
        gameOverWatchAdButton.isHidden = !canContinue

        gameOverTitleLabel.text = "Shawarma dropped!"
        gameOverSubLabel.text = "Orders \(score)/\(goal) · Best \(best)"
        GameTheme.syncShadow(on: gameOverTitleLabel)

        setButtonEnabled(gameOverWatchAdButton, enabled: canContinue, style: .primary)
        setButtonEnabled(gameOverRetryButton, enabled: true, style: .secondary)
        layoutGameOverContent(canContinue: canContinue)

        gameOverPanel.setScale(0.9)
        gameOverPanel.alpha = 0
        gameOverPanel.run(.group([
            .fadeIn(withDuration: 0.18),
            .scale(to: 1.0, duration: 0.22),
        ]))
    }

    func showGameOver(score: Int, goal: Int, best: Int) {
        showGameOver(score: score, goal: goal, best: best, canContinue: false)
    }

    func showContinueCountdown(completion: @escaping () -> Void) {
        hideGameOver()
        hideLevelComplete()

        countdownOverlay.isHidden = false
        countdownLabel.isHidden = false
        countdownCaptionLabel.isHidden = false
        countdownCaptionLabel.text = "Get ready!"
        countdownLabel.text = "3"
        countdownLabel.setScale(0.5)
        countdownLabel.alpha = 1.0
        countdownLabel.removeAction(forKey: "continueCountdown")

        let step = GameConstants.continueCountdownStepDuration
        let sequence = SKAction.sequence([
            countdownStep("3", duration: step),
            countdownStep("2", duration: step),
            countdownStep("1", duration: step),
            SKAction.run { [weak self] in
                self?.countdownCaptionLabel.text = "Go!"
                self?.countdownLabel.text = ""
            },
            SKAction.wait(forDuration: step * 0.45),
            SKAction.run { [weak self] in
                self?.hideContinueCountdown()
                completion()
            },
        ])

        countdownLabel.run(sequence, withKey: "continueCountdown")
    }

    func gameOverAction(at point: CGPoint) -> GameOverAction? {
        guard !gameOverOverlay.isHidden else { return nil }

        if canWatchAdToContinue, buttonHit(gameOverWatchAdButton, at: point) {
            return .watchAd
        }

        if buttonHit(gameOverRetryButton, at: point) {
            return .retry
        }

        return nil
    }

    func showLevelComplete(level: LevelConfig) {
        hideGameOver()
        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        scoreBadge.alpha = 1.0
        updateScore(level.ordersRequired, goal: level.ordersRequired)

        isNextLevelEnabled = level.next != nil
        setButtonEnabled(completeNextButton, enabled: isNextLevelEnabled)

        completeOverlay.isHidden = false
        completePanel.isHidden = false
        completeIcon.isHidden = false
        completeTitleLabel.isHidden = false
        completeMessageLabel.isHidden = false
        completeSubLabel.isHidden = false
        completePlayAgainButton.isHidden = false
        completeNextButton.isHidden = false

        completeTitleLabel.text = "Level Complete!"
        completeMessageLabel.text = "\(level.name) cleared!"
        completeSubLabel.text = "\(level.ordersRequired) orders served"

        GameTheme.syncShadow(on: completeTitleLabel)
        GameTheme.syncShadow(on: completeMessageLabel)
        GameTheme.syncShadow(on: completeSubLabel)

        completePanel.setScale(0.85)
        completePanel.alpha = 0
        completeIcon.setScale(0.2)
        completeIcon.alpha = 0

        completePanel.run(.group([
            .fadeIn(withDuration: 0.2),
            .scale(to: 1.0, duration: 0.25),
        ]))

        completeIcon.run(.sequence([
            .wait(forDuration: 0.12),
            .group([
                .fadeIn(withDuration: 0.18),
                .scale(to: 1.0, duration: 0.28),
            ]),
            .repeatForever(.sequence([
                .scale(to: 1.08, duration: 0.55),
                .scale(to: 1.0, duration: 0.55),
            ])),
        ]))
    }

    func levelCompleteAction(at point: CGPoint) -> LevelCompleteAction? {
        guard !completeOverlay.isHidden else { return nil }

        if buttonHit(completeNextButton, at: point), isNextLevelEnabled {
            return .next
        }

        if buttonHit(completePlayAgainButton, at: point) {
            return .playAgain
        }

        return nil
    }

    private func buttonHit(_ button: SKNode, at point: CGPoint) -> Bool {
        button.calculateAccumulatedFrame().insetBy(dx: -8, dy: -8).contains(point)
    }

    func updateScore(_ score: Int, goal: Int) {
        scoreLabel.text = "\(score) / \(goal)"
        GameTheme.syncShadow(on: scoreLabel)
    }

    private func layoutGameOverContent(canContinue: Bool) {
        gameOverTitleLabel.position = CGPoint(
            x: panelCenter.x,
            y: panelCenter.y + GameOverLayout.titleY
        )
        gameOverSubLabel.position = CGPoint(
            x: panelCenter.x,
            y: panelCenter.y + GameOverLayout.subtitleY
        )

        if canContinue {
            gameOverWatchAdButton.position = CGPoint(
                x: panelCenter.x - GameOverLayout.buttonSpacing,
                y: panelCenter.y + GameOverLayout.buttonsY
            )
            gameOverRetryButton.position = CGPoint(
                x: panelCenter.x + GameOverLayout.buttonSpacing,
                y: panelCenter.y + GameOverLayout.buttonsY
            )
        } else {
            gameOverRetryButton.position = CGPoint(
                x: panelCenter.x,
                y: panelCenter.y + GameOverLayout.singleButtonY
            )
        }
    }

    private func hideContinueCountdown() {
        countdownLabel.removeAction(forKey: "continueCountdown")
        countdownOverlay.isHidden = true
        countdownLabel.isHidden = true
        countdownCaptionLabel.isHidden = true
        countdownLabel.setScale(1.0)
    }

    private func countdownStep(_ value: String, duration: TimeInterval) -> SKAction {
        SKAction.sequence([
            SKAction.run { [weak self] in
                self?.countdownLabel.text = value
                self?.countdownLabel.setScale(0.45)
                self?.countdownLabel.alpha = 0.2
            },
            SKAction.group([
                SKAction.scale(to: 1.0, duration: duration * 0.35),
                SKAction.fadeIn(withDuration: duration * 0.25),
            ]),
            SKAction.wait(forDuration: duration * 0.65),
        ])
    }

    private func hideGameOver() {
        hideContinueCountdown()
        gameOverOverlay.isHidden = true
        gameOverPanel.isHidden = true
        gameOverTitleLabel.isHidden = true
        gameOverSubLabel.isHidden = true
        gameOverWatchAdButton.isHidden = true
        gameOverRetryButton.isHidden = true
        gameOverPanel.removeAllActions()
        gameOverPanel.setScale(1.0)
        gameOverPanel.alpha = 1.0
        canWatchAdToContinue = false
    }

    private func hideLevelComplete() {
        completeOverlay.isHidden = true
        completePanel.isHidden = true
        completeIcon.isHidden = true
        completeTitleLabel.isHidden = true
        completeMessageLabel.isHidden = true
        completeSubLabel.isHidden = true
        completePlayAgainButton.isHidden = true
        completeNextButton.isHidden = true
        completePanel.removeAllActions()
        completeIcon.removeAllActions()
        completePanel.setScale(1.0)
        completeIcon.setScale(1.0)
    }

    private enum ButtonStyle {
        case primary
        case secondary
    }

    private static func makeButton(
        title: String,
        name: String,
        enabled: Bool,
        theme: ThemePalette,
        width: CGFloat = 118,
        style: ButtonStyle = .primary
    ) -> SKNode {
        let container = SKNode()
        container.name = name
        container.zPosition = 33

        let background = SKShapeNode(rectOf: CGSize(width: width, height: 42), cornerRadius: 12)
        background.name = name
        background.zPosition = 0
        container.addChild(background)

        let label = SKLabelNode(fontNamed: GameTheme.bodyFont)
        label.text = title
        label.fontSize = style == .primary ? 15 : 16
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = name
        label.zPosition = 1
        container.addChild(label)

        applyButtonEnabled(container, enabled: enabled, theme: theme, style: style)
        return container
    }

    private static func applyButtonEnabled(
        _ button: SKNode,
        enabled: Bool,
        theme: ThemePalette,
        style: ButtonStyle = .primary
    ) {
        guard let background = button.children.compactMap({ $0 as? SKShapeNode }).first,
              let label = button.children.compactMap({ $0 as? SKLabelNode }).first else { return }

        if enabled {
            switch style {
            case .primary:
                background.fillColor = theme.accent.withAlphaComponent(0.22)
                background.strokeColor = theme.accent
                background.lineWidth = 2
                label.fontColor = theme.accent
            case .secondary:
                background.fillColor = theme.metalMid.withAlphaComponent(0.35)
                background.strokeColor = theme.textPrimary.withAlphaComponent(0.35)
                background.lineWidth = 1.5
                label.fontColor = theme.textPrimary.withAlphaComponent(0.85)
            }
            button.alpha = 1.0
        } else {
            background.fillColor = theme.metalMid.withAlphaComponent(0.5)
            background.strokeColor = theme.metalLight.withAlphaComponent(0.35)
            background.lineWidth = 1.5
            label.fontColor = theme.textPrimary.withAlphaComponent(0.35)
            button.alpha = 0.65
        }
    }

    private func setButtonEnabled(_ button: SKNode, enabled: Bool, style: ButtonStyle = .primary) {
        Self.applyButtonEnabled(button, enabled: enabled, theme: theme, style: style)
    }
}
