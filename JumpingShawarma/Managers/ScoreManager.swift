import Foundation

final class ScoreManager {
    private(set) var current = 0

    var best: Int {
        get { UserDefaults.standard.integer(forKey: GameConstants.bestScoreKey) }
        set { UserDefaults.standard.set(newValue, forKey: GameConstants.bestScoreKey) }
    }

    func reset() {
        current = 0
    }

    @discardableResult
    func increment() -> Int {
        current += 1
        return current
    }

    func saveBestIfNeeded() {
        if current > best {
            best = current
        }
    }
}
