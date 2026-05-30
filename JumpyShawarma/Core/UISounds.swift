import AVFoundation
import AudioToolbox

enum UISounds {
    private static var buttonTapSoundID: SystemSoundID = 0

    static func prepare() {
        loadButtonTapIfNeeded()
        warmAudioSession()
    }

    static func playButtonTap() {
        loadButtonTapIfNeeded()
        guard buttonTapSoundID != 0 else { return }
        AudioServicesPlaySystemSound(buttonTapSoundID)
    }

    private static func loadButtonTapIfNeeded() {
        guard buttonTapSoundID == 0,
              let url = Bundle.main.url(forResource: "buttonTap", withExtension: "caf") else { return }
        AudioServicesCreateSystemSoundID(url as CFURL, &buttonTapSoundID)
    }

    /// Brings CoreAudio up once, ahead of gameplay, so the first SpriteKit
    /// sound doesn't trigger an audio-engine cold start on the main thread.
    private static func warmAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, options: [.mixWithOthers])
        try? session.setActive(true)
    }
}
