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
        case .nightAlley:   30
        case .downtownRush: 40
        case .rooftopShift: 50
        case .forgeFlames:  60
        case .closingTime:  35
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
        case .nightAlley:   .nightAlley
        case .downtownRush: .downtownRush
        case .rooftopShift: .rooftopShift
        case .forgeFlames:  .forgeFlames
        case .closingTime:  .closingTime
        }
    }

    var pipeWidth: CGFloat { 74 }

    var gapHeight: CGFloat {
        switch self {
        case .nightAlley: 200
        case .downtownRush: 190
        case .forgeFlames, .rooftopShift, .closingTime: 175
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
        case .rooftopShift: 82
        case .forgeFlames: 68
        case .closingTime: 55
        default: 0
        }
    }

    var obstacleVerticalDuration: TimeInterval {
        switch self {
        case .rooftopShift: 1.15
        case .forgeFlames: 1.25
        case .closingTime: 0.78
        default: 0
        }
    }

    var readySubtitle: String {
        switch self {
        case .rooftopShift:
            "Serve \(ordersRequired) orders · Gaps move up and down"
        case .forgeFlames:
            "Serve \(ordersRequired) orders · Moving gaps · Dodge the fire"
        case .closingTime:
            "Serve \(ordersRequired) orders · Boss at the end"
        default:
            "Serve \(ordersRequired) orders · Tap to start"
        }
    }

    static func level(for id: Int) -> LevelConfig? {
        LevelConfig(rawValue: id)
    }
}
