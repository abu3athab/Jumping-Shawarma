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
