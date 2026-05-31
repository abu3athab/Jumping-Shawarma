import Foundation

enum LevelConfig: Int, CaseIterable {
    case nightAlley = 1
    case downtownRush = 2
    case rooftopShift = 3
    case forgeFlames = 4
    case closingTime = 5

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
        case .closingTime: return "Closing Time"
        }
    }

    var ordersRequired: Int {
        switch self {
        case .nightAlley: return 30
        case .downtownRush: return 40
        case .rooftopShift: return 50
        case .forgeFlames: return 60
        case .closingTime: return 35
        }
    }
    
    var levelDesciption: String {
        if hasBossFight {
            return "Complete \(ordersRequired) orders · Boss fight"
        }
        return "Complete \(ordersRequired) orders"
    }

    var theme: ThemePalette {
        switch self {
        case .nightAlley: return .nightAlley
        case .downtownRush: return .downtownRush
        case .rooftopShift: return .rooftopShift
        case .forgeFlames: return .forgeFlames
        case .closingTime: return .closingTime
        }
    }

    var pipeWidth: CGFloat { 74 }

    var gapHeight: CGFloat {
        switch self {
        case .forgeFlames: return 228
        case .closingTime: return 170
        default: return GameConstants.gapHeight
        }
    }

    var hasMovingObstacles: Bool {
        switch self {
        case .rooftopShift, .forgeFlames, .closingTime: return true
        default: return false
        }
    }

    var hasFireShooters: Bool {
        switch self {
        case .forgeFlames: return true
        default: return false
        }
    }

    var hasBossFight: Bool {
        switch self {
        case .closingTime: return true
        default: return false
        }
    }

    var obstacleVerticalAmplitude: CGFloat {
        switch self {
        case .rooftopShift: return 82
        case .forgeFlames: return 68
        case .closingTime: return 55
        default: return 0
        }
    }

    var obstacleVerticalDuration: TimeInterval {
        switch self {
        case .rooftopShift: return 1.15
        case .forgeFlames: return 1.25
        case .closingTime: return 0.78
        default: return 0
        }
    }

    var readySubtitle: String {
        switch self {
        case .rooftopShift:
            return "Serve \(ordersRequired) orders · Gaps move up and down"
        case .forgeFlames:
            return "Serve \(ordersRequired) orders · Moving gaps · Dodge the fire"
        case .closingTime:
            return "Serve \(ordersRequired) orders · Boss at the end"
        default:
            return "Serve \(ordersRequired) orders · Tap to start"
        }
    }

    static func level(for id: Int) -> LevelConfig? {
        LevelConfig(rawValue: id)
    }
}
