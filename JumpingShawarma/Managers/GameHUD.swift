import SpriteKit

enum LevelCompleteAction {
    case next
    case playAgain
}

final class GameHUD {
    static let nextButtonName = "levelCompleteNext"
    static let playAgainButtonName = "levelCompletePlayAgain"

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

    private var isNextLevelEnabled = false
    private var panelCenter = CGPoint.zero
    private let theme: ThemePalette

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

        GameTheme.attachShadow(to: scoreLabel)
        GameTheme.attachShadow(to: messageLabel)
        GameTheme.attachShadow(to: subMessageLabel)
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
    }

    func showReady(level: LevelConfig) {
        hideLevelComplete()
        scoreCaptionLabel.text = "LEVEL \(level.id) · ORDERS"
        updateScore(0, goal: level.ordersRequired)
        messageLabel.text = level.name
        subMessageLabel.text = "Serve \(level.ordersRequired) orders · Tap to start"
        GameTheme.syncShadow(on: messageLabel)
        GameTheme.syncShadow(on: subMessageLabel)
        scoreBadge.alpha = 0.55
    }

    func showPlaying(level: LevelConfig) {
        hideLevelComplete()
        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        GameTheme.syncShadow(on: subMessageLabel)
        scoreBadge.alpha = 1.0
        updateScore(0, goal: level.ordersRequired)
    }

    func showGameOver(score: Int, goal: Int, best: Int) {
        hideLevelComplete()
        messageLabel.text = "Shawarma dropped!"
        subMessageLabel.text = "Orders \(score)/\(goal) · Best \(best)\nTap to try again"
        GameTheme.syncShadow(on: messageLabel)
        GameTheme.syncShadow(on: subMessageLabel)
        scoreBadge.alpha = 0.75
    }

    func showLevelComplete(level: LevelConfig) {
        messageLabel.text = ""
        subMessageLabel.text = ""
        GameTheme.syncShadow(on: messageLabel)
        GameTheme.syncShadow(on: subMessageLabel)
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

    private static func makeButton(
        title: String,
        name: String,
        enabled: Bool,
        theme: ThemePalette
    ) -> SKNode {
        let container = SKNode()
        container.name = name
        container.zPosition = 33

        let background = SKShapeNode(rectOf: CGSize(width: 118, height: 42), cornerRadius: 12)
        background.name = name
        background.zPosition = 0
        container.addChild(background)

        let label = SKLabelNode(fontNamed: GameTheme.bodyFont)
        label.text = title
        label.fontSize = 16
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = name
        label.zPosition = 1
        container.addChild(label)

        applyButtonEnabled(container, enabled: enabled, theme: theme)
        return container
    }

    private static func applyButtonEnabled(_ button: SKNode, enabled: Bool, theme: ThemePalette) {
        guard let background = button.children.compactMap({ $0 as? SKShapeNode }).first,
              let label = button.children.compactMap({ $0 as? SKLabelNode }).first else { return }

        if enabled {
            background.fillColor = theme.accent.withAlphaComponent(0.22)
            background.strokeColor = theme.accent
            background.lineWidth = 2
            label.fontColor = theme.accent
            button.alpha = 1.0
        } else {
            background.fillColor = theme.metalMid.withAlphaComponent(0.5)
            background.strokeColor = theme.metalLight.withAlphaComponent(0.35)
            background.lineWidth = 1.5
            label.fontColor = theme.textPrimary.withAlphaComponent(0.35)
            button.alpha = 0.65
        }
    }

    private func setButtonEnabled(_ button: SKNode, enabled: Bool) {
        Self.applyButtonEnabled(button, enabled: enabled, theme: theme)
    }
}
