import SpriteKit

enum GameAssetLoader {
    private static var didPreload = false

    static func preloadIfNeeded() {
        guard !didPreload else { return }
        didPreload = true
        UISounds.prepare()
        BirdNode.preloadAssets()
        PipeNode.preloadTextures()
    }
}
