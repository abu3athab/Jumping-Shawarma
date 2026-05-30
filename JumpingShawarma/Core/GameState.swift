enum GameState {
    case ready
    case playing
    case victoryRun
    case gameOver
    case continueCountdown
    case levelComplete

    var isPlaying: Bool {
        self == .playing
    }
}
