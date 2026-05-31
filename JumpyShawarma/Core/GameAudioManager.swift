import AVFoundation
import AudioToolbox
import SpriteKit

final class GameAudioManager {
    static let shared = GameAudioManager()

    private var isPrepared = false
    private var buttonTapSoundID: SystemSoundID = 0

    private(set) lazy var jumpAction: SKAction = {
        SKAction.playSoundFileNamed("jumpSound.caf", waitForCompletion: false)
    }()

    private(set) lazy var gameOverAction: SKAction = {
        SKAction.playSoundFileNamed("gameOverSound.caf", waitForCompletion: false)
    }()

    private init() {}

    func prepare() {
        guard !isPrepared else { return }
        isPrepared = true

        warmAudioSession()
        loadButtonTapIfNeeded()
        _ = jumpAction
        _ = gameOverAction
    }

    func playButtonTap() {
        loadButtonTapIfNeeded()
        guard buttonTapSoundID != 0 else { return }
        AudioServicesPlaySystemSound(buttonTapSoundID)
    }

    private func loadButtonTapIfNeeded() {
        guard buttonTapSoundID == 0,
              let url = Bundle.main.url(forResource: "buttonTap", withExtension: "caf") else { return }
        AudioServicesCreateSystemSoundID(url as CFURL, &buttonTapSoundID)
    }

    private func warmAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true)
    }
}
