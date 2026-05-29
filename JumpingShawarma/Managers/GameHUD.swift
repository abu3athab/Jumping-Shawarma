import SpriteKit

final class GameHUD {
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

    init(sceneSize: CGSize) {
        scoreBadge = SKShapeNode(rectOf: GameHUDLayout.scoreBadgeSize, cornerRadius: 14)
        scoreBadge.fillColor = GameTheme.color(0.1, 0.07, 0.06, 0.72)
        scoreBadge.strokeColor = GameTheme.gold.withAlphaComponent(0.55)
        scoreBadge.lineWidth = 2
        scoreBadge.zPosition = 19

        scoreCaptionLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        scoreCaptionLabel.fontSize = 13
        scoreCaptionLabel.fontColor = GameTheme.cream.withAlphaComponent(0.85)
        scoreCaptionLabel.verticalAlignmentMode = .center
        scoreCaptionLabel.zPosition = 20

        scoreLabel = SKLabelNode(fontNamed: GameTheme.scoreFont)
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = GameTheme.gold
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 20
        scoreLabel.text = "0"

        messageLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        messageLabel.fontSize = 30
        messageLabel.fontColor = GameTheme.cream
        messageLabel.zPosition = 20

        subMessageLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        subMessageLabel.fontSize = 17
        subMessageLabel.fontColor = GameTheme.gold.withAlphaComponent(0.95)
        subMessageLabel.zPosition = 20

        completeOverlay = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        completeOverlay.fillColor = GameTheme.color(0.05, 0.03, 0.02, 0.62)
        completeOverlay.strokeColor = .clear
        completeOverlay.zPosition = 30
        completeOverlay.isHidden = true

        completePanel = SKShapeNode(rectOf: CGSize(width: 300, height: 250), cornerRadius: 22)
        completePanel.fillColor = GameTheme.color(0.12, 0.08, 0.06, 0.94)
        completePanel.strokeColor = GameTheme.gold
        completePanel.lineWidth = 3
        completePanel.zPosition = 31
        completePanel.isHidden = true

        completeIcon = SKShapeNode(circleOfRadius: 28)
        completeIcon.fillColor = GameTheme.gold.withAlphaComponent(0.18)
        completeIcon.strokeColor = GameTheme.gold
        completeIcon.lineWidth = 3
        completeIcon.zPosition = 32
        completeIcon.isHidden = true

        let checkmark = SKLabelNode(fontNamed: GameTheme.titleFont)
        checkmark.text = "✓"
        checkmark.fontSize = 34
        checkmark.fontColor = GameTheme.gold
        checkmark.verticalAlignmentMode = .center
        checkmark.horizontalAlignmentMode = .center
        checkmark.position = .zero
        checkmark.zPosition = 1
        completeIcon.addChild(checkmark)

        completeTitleLabel = SKLabelNode(fontNamed: GameTheme.titleFont)
        completeTitleLabel.fontSize = 28
        completeTitleLabel.fontColor = GameTheme.gold
        completeTitleLabel.text = "Level Complete!"
        completeTitleLabel.zPosition = 32
        completeTitleLabel.isHidden = true

        completeMessageLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        completeMessageLabel.fontSize = 20
        completeMessageLabel.fontColor = GameTheme.cream
        completeMessageLabel.zPosition = 32
        completeMessageLabel.isHidden = true

        completeSubLabel = SKLabelNode(fontNamed: GameTheme.bodyFont)
        completeSubLabel.fontSize = 16
        completeSubLabel.fontColor = GameTheme.gold.withAlphaComponent(0.9)
        completeSubLabel.zPosition = 32
        completeSubLabel.isHidden = true

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

        let center = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.5)
        completePanel.position = center
        completeIcon.position = CGPoint(x: center.x, y: center.y + 72)
        completeTitleLabel.position = CGPoint(x: center.x, y: center.y + 18)
        completeMessageLabel.position = CGPoint(x: center.x, y: center.y - 18)
        completeSubLabel.position = CGPoint(x: center.x, y: center.y - 72)

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

        completeOverlay.isHidden = false
        completePanel.isHidden = false
        completeIcon.isHidden = false
        completeTitleLabel.isHidden = false
        completeMessageLabel.isHidden = false
        completeSubLabel.isHidden = false

        completeTitleLabel.text = "Level Complete!"
        completeMessageLabel.text = "\(level.name) cleared!"
        completeSubLabel.text = "\(level.ordersRequired) orders served\nTap to return to levels"

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
        completePanel.removeAllActions()
        completeIcon.removeAllActions()
        completePanel.setScale(1.0)
        completeIcon.setScale(1.0)
    }
}
