import Foundation

enum LevelConfig: Int, CaseIterable {
    case nightAlley = 1

    var id: Int { rawValue }

    var previous: LevelConfig? {
        LevelConfig(rawValue: rawValue - 1)
    }

    var next: LevelConfig? {
        LevelConfig(rawValue: rawValue + 1)
    }

    var name: String {
        switch self {
        case .nightAlley: return "Night Alley"
        }
    }

    var ordersRequired: Int {
        switch self {
        case .nightAlley: return 2
        }
    }

    static func level(for id: Int) -> LevelConfig? {
        LevelConfig(rawValue: id)
    }
}
