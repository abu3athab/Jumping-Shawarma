import AVFoundation
import SpriteKit

final class GameAudioManager {
    static let shared = GameAudioManager()

    private var isPrepared = false
    private var buttonTapPlayer: AVAudioPlayer?

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
        guard let buttonTapPlayer else { return }
        if buttonTapPlayer.isPlaying {
            buttonTapPlayer.currentTime = 0
        }
        buttonTapPlayer.play()
    }

    private func loadButtonTapIfNeeded() {
        guard buttonTapPlayer == nil,
              let url = Bundle.main.url(forResource: "buttonTap", withExtension: "caf") else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            buttonTapPlayer = player
        } catch {
            print("Button tap sound failed to load: \(error.localizedDescription)")
        }
    }

    private func warmAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true)
    }
}
