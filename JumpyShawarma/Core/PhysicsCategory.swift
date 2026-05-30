enum PhysicsCategory {
    static let none: UInt32 = 0
    static let bird: UInt32 = 0x1 << 0
    static let pipe: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let score: UInt32 = 0x1 << 3
    static let fire: UInt32 = 0x1 << 4
}
