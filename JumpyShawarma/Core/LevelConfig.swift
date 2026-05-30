import Foundation

enum LevelConfig: Int, CaseIterable {
    case nightAlley = 1
    case downtownRush = 2
    case rooftopShift = 3
    case forgeFlames = 4

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
        case .rooftopShift: return "Rooftop Shift"
        case .forgeFlames: return "Forge Flames"
        }
    }

    var ordersRequired: Int {
        switch self {
        case .nightAlley: return 30
        case .downtownRush: return 40
        case .rooftopShift: return 50
        case .forgeFlames: return 60
        }
    }

    var theme: ThemePalette {
        switch self {
        case .nightAlley: return .nightAlley
        case .downtownRush: return .downtownRush
        case .rooftopShift: return .rooftopShift
        case .forgeFlames: return .forgeFlames
        }
    }

    var pipeWidth: CGFloat { 74 }

    var hasMovingObstacles: Bool {
        switch self {
        case .rooftopShift, .forgeFlames: return true
        default: return false
        }
    }

    var hasFireShooters: Bool {
        switch self {
        case .forgeFlames: return true
        default: return false
        }
    }

    var obstacleVerticalAmplitude: CGFloat {
        switch self {
        case .rooftopShift: return 82
        case .forgeFlames: return 68
        default: return 0
        }
    }

    var obstacleVerticalDuration: TimeInterval {
        switch self {
        case .rooftopShift: return 1.15
        case .forgeFlames: return 1.25
        default: return 0
        }
    }

    var readySubtitle: String {
        switch self {
        case .rooftopShift:
            return "Serve \(ordersRequired) orders · Gaps move up and down"
        case .forgeFlames:
            return "Serve \(ordersRequired) orders · Moving gaps · Dodge the fire"
        default:
            return "Serve \(ordersRequired) orders · Tap to start"
        }
    }

    var featureSummary: String {
        switch self {
        case .rooftopShift:
            return "\(ordersRequired) orders · Moving gaps"
        case .forgeFlames:
            return "\(ordersRequired) orders · Moving gaps · Fire"
        default:
            return "Serve \(ordersRequired) orders"
        }
    }

    static func level(for id: Int) -> LevelConfig? {
        LevelConfig(rawValue: id)
    }
}
