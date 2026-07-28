enum GameState {
    case ready
    case playing
    case bossFight
    case victoryRun
    case gameOver
    case continueCountdown
    case levelComplete

    var isPlaying: Bool {
        self == .playing
    }

    var isBossFight: Bool {
        self == .bossFight
    }
}
