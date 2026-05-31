import SpriteKit

enum GameAssetLoader {
    private static var didPreload = false

    static func preloadIfNeeded() {
        guard !didPreload else { return }
        didPreload = true
        GameAudioManager.shared.prepare()
        BirdNode.preloadAssets()
        PipeNode.preloadTextures()
    }
}
