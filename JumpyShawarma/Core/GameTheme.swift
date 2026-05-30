import SpriteKit

enum GameTheme {
    static let background = color(0.42, 0.2, 0.16)
    static let ember = color(1.0, 0.45, 0.12)
    static let emberGlow = color(1.0, 0.62, 0.18, 0.55)
    static let gold = color(1.0, 0.84, 0.35)
    static let cream = color(0.98, 0.93, 0.82)
    static let metalDark = color(0.18, 0.16, 0.15)
    static let metalMid = color(0.32, 0.29, 0.27)
    static let metalLight = color(0.58, 0.54, 0.5)
    static let pavement = color(0.34, 0.26, 0.2)
    static let pavementLight = color(0.42, 0.33, 0.26)
    static let counter = color(0.72, 0.7, 0.66)
    static let awning = color(0.62, 0.14, 0.12)
    static let steam = color(1.0, 1.0, 1.0, 0.18)

    static let titleFont = "AvenirNext-Heavy"
    static let bodyFont = "AvenirNext-DemiBold"
    static let scoreFont = "AvenirNext-Bold"

    static func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> SKColor {
        SKColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    static func attachShadow(to label: SKLabelNode, offset: CGPoint = CGPoint(x: 0, y: -2)) {
        let shadow = SKLabelNode(fontNamed: label.fontName)
        shadow.fontSize = label.fontSize
        shadow.fontColor = color(0.08, 0.05, 0.04, 0.75)
        shadow.text = label.text
        shadow.horizontalAlignmentMode = label.horizontalAlignmentMode
        shadow.verticalAlignmentMode = label.verticalAlignmentMode
        shadow.position = offset
        shadow.zPosition = -1
        shadow.name = "labelShadow"
        label.addChild(shadow)
    }

    static func syncShadow(on label: SKLabelNode) {
        label.childNode(withName: "labelShadow").map { node in
            (node as? SKLabelNode)?.text = label.text
        }
    }

    static func pulse(node: SKNode, minAlpha: CGFloat = 0.55, maxAlpha: CGFloat = 1.0, duration: TimeInterval = 0.9) {
        node.run(.repeatForever(.sequence([
            .fadeAlpha(to: maxAlpha, duration: duration),
            .fadeAlpha(to: minAlpha, duration: duration),
        ])))
    }
}

enum LevelThemeID {
    case nightAlley
    case downtownRush
    case rooftopShift
}

struct ThemePalette {
    let id: LevelThemeID
    let background: SKColor
    let accent: SKColor
    let accentSecondary: SKColor
    let accentGlow: SKColor
    let textPrimary: SKColor
    let metalDark: SKColor
    let metalMid: SKColor
    let metalLight: SKColor
    let groundDark: SKColor
    let groundLight: SKColor
    let groundGlow: SKColor
    let counter: SKColor
    let awning: SKColor
    let silhouette: SKColor
    let wire: SKColor

    static let nightAlley = ThemePalette(
        id: .nightAlley,
        background: GameTheme.color(0.42, 0.2, 0.16),
        accent: GameTheme.color(1.0, 0.84, 0.35),
        accentSecondary: GameTheme.color(1.0, 0.45, 0.12),
        accentGlow: GameTheme.color(1.0, 0.62, 0.18, 0.55),
        textPrimary: GameTheme.color(0.98, 0.93, 0.82),
        metalDark: GameTheme.color(0.18, 0.16, 0.15),
        metalMid: GameTheme.color(0.32, 0.29, 0.27),
        metalLight: GameTheme.color(0.58, 0.54, 0.5),
        groundDark: GameTheme.color(0.34, 0.26, 0.2),
        groundLight: GameTheme.color(0.42, 0.33, 0.26),
        groundGlow: GameTheme.color(1.0, 0.62, 0.18, 0.55),
        counter: GameTheme.color(0.72, 0.7, 0.66),
        awning: GameTheme.color(0.62, 0.14, 0.12),
        silhouette: GameTheme.color(0.08, 0.05, 0.06, 0.55),
        wire: GameTheme.color(0.2, 0.16, 0.14, 0.7)
    )

    static let downtownRush = ThemePalette(
        id: .downtownRush,
        background: GameTheme.color(0.07, 0.09, 0.2),
        accent: GameTheme.color(0.35, 0.92, 1.0),
        accentSecondary: GameTheme.color(1.0, 0.35, 0.78),
        accentGlow: GameTheme.color(0.35, 0.92, 1.0, 0.45),
        textPrimary: GameTheme.color(0.92, 0.95, 1.0),
        metalDark: GameTheme.color(0.14, 0.16, 0.24),
        metalMid: GameTheme.color(0.22, 0.24, 0.34),
        metalLight: GameTheme.color(0.45, 0.48, 0.58),
        groundDark: GameTheme.color(0.16, 0.17, 0.22),
        groundLight: GameTheme.color(0.22, 0.23, 0.3),
        groundGlow: GameTheme.color(1.0, 0.35, 0.78, 0.45),
        counter: GameTheme.color(0.28, 0.3, 0.38),
        awning: GameTheme.color(0.2, 0.55, 0.95),
        silhouette: GameTheme.color(0.04, 0.05, 0.12, 0.75),
        wire: GameTheme.color(0.25, 0.28, 0.4, 0.6)
    )

    static let rooftopShift = ThemePalette(
        id: .rooftopShift,
        background: GameTheme.color(0.3, 0.14, 0.2),
        accent: GameTheme.color(1.0, 0.62, 0.28),
        accentSecondary: GameTheme.color(0.95, 0.42, 0.55),
        accentGlow: GameTheme.color(1.0, 0.48, 0.22, 0.5),
        textPrimary: GameTheme.color(0.98, 0.9, 0.82),
        metalDark: GameTheme.color(0.2, 0.14, 0.16),
        metalMid: GameTheme.color(0.34, 0.24, 0.22),
        metalLight: GameTheme.color(0.58, 0.46, 0.42),
        groundDark: GameTheme.color(0.28, 0.18, 0.16),
        groundLight: GameTheme.color(0.38, 0.26, 0.22),
        groundGlow: GameTheme.color(1.0, 0.48, 0.22, 0.45),
        counter: GameTheme.color(0.52, 0.38, 0.32),
        awning: GameTheme.color(0.72, 0.22, 0.18),
        silhouette: GameTheme.color(0.12, 0.06, 0.08, 0.65),
        wire: GameTheme.color(0.35, 0.22, 0.18, 0.55)
    )
}
