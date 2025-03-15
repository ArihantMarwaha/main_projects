import Foundation
import SwiftUI

// Achievement Types
public enum AchievementType: String, Codable, CaseIterable {
    case waterStreak = "Hydration Master"
    case mealStreak = "Nutrition Expert"
    case breakStreak = "Break Champion"
    case perfectDay = "Perfect Day"
    case perfectWeek = "Perfect Week"
    case petCare = "Pet Whisperer"
    case consistency = "Consistency King"
    
    public var description: String {
        switch self {
        case .waterStreak: return "Maintain a streak of hitting water intake goals"
        case .mealStreak: return "Keep up with regular meals and snacks"
        case .breakStreak: return "Take regular breaks consistently"
        case .perfectDay: return "Complete all daily goals"
        case .perfectWeek: return "Complete all goals for an entire week"
        case .petCare: return "Keep your pet happy and healthy"
        case .consistency: return "Maintain consistent daily routines"
        }
    }
    
    public var icon: String {
        switch self {
        case .waterStreak: return "drop.fill"
        case .mealStreak: return "fork.knife"
        case .breakStreak: return "figure.walk"
        case .perfectDay: return "star.fill"
        case .perfectWeek: return "trophy.fill"
        case .petCare: return "heart.fill"
        case .consistency: return "clock.badge.checkmark"
        }
    }
}

// Achievement Levels
public enum AchievementLevel: Int, Codable, Comparable {
    case bronze = 1
    case silver = 2
    case gold = 3
    case platinum = 4
    
    public var name: String { rawValue.description }
    public var color: Color {
        switch self {
        case .bronze: return .brown
        case .silver: return .gray
        case .gold: return .yellow
        case .platinum: return .purple
        }
    }
    
    public static func < (lhs: AchievementLevel, rhs: AchievementLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// Achievement Requirements
public struct AchievementCriteria: Codable {
    public let type: AchievementType
    public let level: AchievementLevel
    public let requiredCount: Int
    public let description: String
} 
