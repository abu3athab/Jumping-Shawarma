import Foundation

enum LevelProgress {
    private static let completedLevelsKey = "jumping_shawarma_completed_levels"

    static func isCompleted(_ level: LevelConfig) -> Bool {
        isCompleted(level.id)
    }

    static func isCompleted(_ levelID: Int) -> Bool {
        completedLevelIDs().contains(levelID)
    }

    static func isUnlocked(_ level: LevelConfig) -> Bool {
        guard let previous = level.previous else { return true }
        return isCompleted(previous)
    }

    static func markCompleted(_ level: LevelConfig) {
        markCompleted(level.id)
    }

    static func markCompleted(_ levelID: Int) {
        var completed = completedLevelIDs()
        guard !completed.contains(levelID) else { return }
        completed.append(levelID)
        UserDefaults.standard.set(completed, forKey: completedLevelsKey)
    }

    private static func completedLevelIDs() -> [Int] {
        UserDefaults.standard.array(forKey: completedLevelsKey) as? [Int] ?? []
    }
}
