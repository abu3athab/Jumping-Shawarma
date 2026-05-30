import SpriteKit
import SwiftUI

struct GameSpriteView: UIViewRepresentable {
    let scene: GameScene
    let backgroundColor: UIColor

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.backgroundColor = backgroundColor
        view.ignoresSiblingOrder = true
        view.allowsTransparency = false
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        view.backgroundColor = backgroundColor
        if view.scene !== scene {
            view.presentScene(scene)
        }
    }
}
