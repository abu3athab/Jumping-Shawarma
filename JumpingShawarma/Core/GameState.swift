enum GameState {
    case ready
    case playing
    case gameOver
    case levelComplete

    var isPlaying: Bool {
        self == .playing
    }
}
