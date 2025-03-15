import Foundation
import SwiftUI

struct WeeklyAnalytics: Codable, Identifiable, Equatable {
    let id: UUID
    let weekStartDate: Date
    let goalId: UUID
    var dailyData: [DailyProgressData]
    
    var weeklyCompletionRate: Double {
        guard !dailyData.isEmpty else { return 0 }
        let totalCompleted = dailyData.reduce(0) { $0 + $1.completedCount }
        let totalTarget = dailyData.reduce(0) { $0 + $1.targetCount }
        // Allow completion rate to exceed 100% if more than target is completed
        return totalTarget > 0 ? Double(totalCompleted) / Double(totalTarget) : 0
    }
    
    var maxCompletionRate: Double {
        // Find the highest daily completion rate
        dailyData.map { $0.completionRate }.max() ?? 0
    }
    
    var averageCompletionsPerDay: Double {
        guard !dailyData.isEmpty else { return 0 }
        let totalCompleted = dailyData.reduce(0) { $0 + $1.completedCount }
        return Double(totalCompleted) / Double(dailyData.count)
    }
    
    var totalCompletions: Int {
        dailyData.reduce(0) { $0 + $1.completedCount }
    }
    
    var isPerfectWeek: Bool {
        // Check if we have data for all days and each day meets or exceeds its target
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.startOfWeek()
        
        // Only count days up to today
        let daysToCheck = dailyData.filter { day in
            day.date >= weekStart && day.date <= today
        }
        
        // All checked days must meet or exceed target
        return !daysToCheck.isEmpty && daysToCheck.allSatisfy { day in
            day.completedCount >= day.targetCount
        }
    }
    
    var isPerfectDay: Bool {
        guard let today = dailyData.first(where: { Calendar.current.isDateInToday($0.date) }) else {
            return false
        }
        return today.completedCount >= today.targetCount
    }
    
    var dailyCompletionRate: Double {
        guard let today = dailyData.first(where: {
            Calendar.current.isDateInToday($0.date)
        }) else { return 0 }
        return today.completionRate
    }
    
    var averageCompletionTime: TimeInterval? {
        let allTimes = dailyData.flatMap { $0.completionTime }
        guard !allTimes.isEmpty else { return nil }
        
        let secondsFromDayStart = allTimes.compactMap { date -> Int? in
            let calendar = Calendar.current
            let dayStart = calendar.startOfDay(for: date)
            return calendar.dateComponents([.second], from: dayStart, to: date).second
        }
        
        return TimeInterval(secondsFromDayStart.reduce(0, +) / secondsFromDayStart.count)
    }
    
    // Updated graph scaling methods
    var maxGraphValue: Int {
        let maxCompleted = dailyData.map { $0.completedCount }.max() ?? 0
        let maxTarget = dailyData.map { $0.targetCount }.max() ?? 0
        let maxValue = max(maxCompleted, maxTarget)
        
        // Add 50% headroom for overachievement
        return Int(Double(maxValue) * 1.5).roundedUpToNearestMultiple(of: 5)
    }
    
    // Get Y-axis labels with better distribution
    var graphYAxisLabels: [String] {
        let max = maxGraphValue
        let numberOfLabels = 5
        let step = (max + numberOfLabels - 1) / numberOfLabels // Round up division
        
        return stride(from: 0, through: max, by: step).map { String($0) }
    }
    
    // Get graph scale for better visualization
    var graphScale: Double {
        let maxValue = Double(maxGraphValue)
        return maxValue > 0 ? 1.0 / maxValue : 1.0
    }
    
    // Get normalized graph points with better scaling
    var graphDataPoints: [(date: Date, completed: Double, target: Double, status: AchievementStatus)] {
        dailyData.map { data in
            (
                date: data.date,
                completed: Double(data.completedCount) * graphScale,
                target: Double(data.targetCount) * graphScale,
                status: achievementStatus(for: data)
            )
        }
    }
    
    // Get graph grid lines positions
    var gridLines: [Double] {
        let numberOfLines = 4
        return (0...numberOfLines).map { Double($0) / Double(numberOfLines) }
    }
    
    // Check if graph needs rescaling
    var needsRescaling: Bool {
        let maxCompleted = dailyData.map { $0.completedCount }.max() ?? 0
        let maxTarget = dailyData.map { $0.targetCount }.max() ?? 0
        return maxCompleted > maxTarget
    }
    
    // Get achievement status for a specific day
    func achievementStatus(for data: DailyProgressData) -> AchievementStatus {
        if data.isOverAchieved {
            return .overachieved
        } else if data.completedCount == data.targetCount {
            return .achieved
        } else if data.completedCount > 0 {
            return .partial
        } else {
            return .none
        }
    }
    
    // Helper method to get formatted statistics
    func getStatistics() -> [String: String] {
        [
            "Weekly Rate": "\(Int(weeklyCompletionRate * 100))%",
            "Best Day": "\(Int(maxCompletionRate * 100))%",
            "Daily Average": String(format: "%.1f", averageCompletionsPerDay),
            "Total": "\(totalCompletions)"
        ]
    }
    
    static func == (lhs: WeeklyAnalytics, rhs: WeeklyAnalytics) -> Bool {
        lhs.id == rhs.id &&
        lhs.weekStartDate == rhs.weekStartDate &&
        lhs.goalId == rhs.goalId &&
        lhs.dailyData == rhs.dailyData
    }
}

struct DailyProgressData: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let goalId: UUID
    let completedCount: Int
    let targetCount: Int
    let completionTime: [Date]
    
    var completionRate: Double {
        guard targetCount > 0 else { return 0 }
        // Allow completion rate to exceed 100%
        return Double(completedCount) / Double(targetCount)
    }
    
    var overachievement: Int {
        max(0, completedCount - targetCount)
    }
    
    var isOverAchieved: Bool {
        completedCount > targetCount
    }
    
    // Updated achievement percentage calculation
    var achievementPercentage: Int {
        guard targetCount > 0 else { return 0 }
        // Cap the percentage at 200% for display purposes
        return min(200, Int((Double(completedCount) / Double(targetCount) * 100).rounded()))
    }
    
    // Updated achievement string with better formatting
    var achievementString: String {
        if isOverAchieved {
            return "\(completedCount)/\(targetCount) (+\(overachievement))"
        } else {
            return "\(completedCount)/\(targetCount)"
        }
    }
    
    static func == (lhs: DailyProgressData, rhs: DailyProgressData) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.goalId == rhs.goalId &&
        lhs.completedCount == rhs.completedCount &&
        lhs.targetCount == rhs.targetCount &&
        lhs.completionTime == rhs.completionTime
    }
}

// Achievement status for coloring and labeling
enum AchievementStatus {
    case none
    case partial
    case achieved
    case overachieved
    
    var color: Color {
        switch self {
        case .none: return .gray
        case .partial: return .orange
        case .achieved: return .green
        case .overachieved: return .purple
        }
    }
    
    var label: String {
        switch self {
        case .none: return "Not Started"
        case .partial: return "In Progress"
        case .achieved: return "Achieved"
        case .overachieved: return "Exceeded"
        }
    }
}

extension Calendar {
    func startOfWeek(for date: Date = Date()) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

// Helper extension for rounding
extension Int {
    func roundedUpToNearestMultiple(of multiple: Int) -> Int {
        let remainder = self % multiple
        return remainder == 0 ? self : self + multiple - remainder
    }
}

