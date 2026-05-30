import Foundation

enum LevelConfig: Int, CaseIterable {
    case nightAlley = 1
    case downtownRush = 2

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
        case .downtownRush: return "Downtown Rush"
        }
    }

    var ordersRequired: Int {
        switch self {
        case .nightAlley: return 30
        case .downtownRush: return 40
        }
    }

    var theme: ThemePalette {
        switch self {
        case .nightAlley: return .nightAlley
        case .downtownRush: return .downtownRush
        }
    }

    static func level(for id: Int) -> LevelConfig? {
        LevelConfig(rawValue: id)
    }
}
