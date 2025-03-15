import Foundation

public struct Achievement: Identifiable, Codable, Equatable {
    public let id: UUID
    public let type: AchievementType
    public let level: AchievementLevel
    public let dateEarned: Date
    public private(set) var progress: Double
    public private(set) var isCompleted: Bool
    public private(set) var streakCount: Int
    public private(set) var targetValue: Int
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateEarned)
    }
    
    public init(
        type: AchievementType,
        level: AchievementLevel = .bronze,
        dateEarned: Date = Date(),
        progress: Double = 0.0,
        isCompleted: Bool = false,
        streakCount: Int = 0,
        targetValue: Int = 0
    ) {
        self.id = UUID()
        self.type = type
        self.level = level
        self.dateEarned = dateEarned
        self.progress = progress
        self.isCompleted = isCompleted
        self.streakCount = streakCount
        self.targetValue = targetValue
    }
    
    mutating func updateProgress(newProgress: Double) {
        // Ensure progress is between 0 and 1
        progress = min(1.0, max(0.0, newProgress))
        isCompleted = progress >= 1.0
    }
    
    // Helper method to get the target for current level
    public func getTargetForCurrentLevel() -> Int {
        switch type {
        case .waterStreak:
            return level.waterTargets
        case .mealStreak:
            return level.mealTargets
        case .breakStreak:
            return level.breakTargets
        case .petCare:
            return level.petCareTargets
        case .consistency:
            return level.consistencyTargets
        case .perfectDay:
            return level.consistencyTargets // Use consistency targets for perfect day
        case .perfectWeek:
            return level.consistencyTargets // Use consistency targets for perfect week
        @unknown default:  // Add @unknown default case for future enum cases
            return level.consistencyTargets // Default to consistency targets
        }
    }
    
    // Add Equatable conformance
    public static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id &&
        lhs.type == rhs.type &&
        lhs.level == rhs.level &&
        lhs.dateEarned == rhs.dateEarned &&
        lhs.progress == rhs.progress &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.streakCount == rhs.streakCount &&
        lhs.targetValue == rhs.targetValue
    }
}

// Add target values for each level
extension AchievementLevel {
    var waterTargets: Int {
        switch self {
        case .bronze: return 3  // 3 water breaks in a day
        case .silver: return 5  // 5 water breaks in a day
        case .gold: return 7    // 7 water breaks in a day
        case .platinum: return 10 // 10 water breaks in a day
        }
    }
    
    var mealTargets: Int {
        switch self {
        case .bronze: return 3  // 3 meals in a day
        case .silver: return 4  // 4 meals in a day
        case .gold: return 5    // 5 meals in a day
        case .platinum: return 6 // 6 meals/snacks in a day
        }
    }
    
    var breakTargets: Int {
        switch self {
        case .bronze: return 2  // 2 breaks in a day
        case .silver: return 4  // 4 breaks in a day
        case .gold: return 6    // 6 breaks in a day
        case .platinum: return 8 // 8 breaks in a day
        }
    }
    
    var petCareTargets: Int {
        switch self {
        case .bronze: return 70  // 70% average stats
        case .silver: return 80  // 80% average stats
        case .gold: return 90    // 90% average stats
        case .platinum: return 95 // 95% average stats
        }
    }
    
    var consistencyTargets: Int {
        switch self {
        case .bronze: return 3   // 3 days streak
        case .silver: return 7   // 7 days streak
        case .gold: return 14    // 14 days streak
        case .platinum: return 30 // 30 days streak
        }
    }
} 