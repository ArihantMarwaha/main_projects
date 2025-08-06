import Foundation
import SwiftUI
import Combine

// Add this extension at the top of the file, before the AnalyticsManager class
extension MealGoalTracker.MealType {
    static func from(_ string: String) -> MealGoalTracker.MealType? {
        return MealGoalTracker.MealType(rawValue: string)
    }
}

@MainActor
class AnalyticsManager: ObservableObject {
    private let repository = AnalyticsRepository()
    @Published private(set) var weeklyAnalytics: [UUID: WeeklyAnalytics] = [:]
    
    init() {
        loadData()
        setupWeeklyReset()
    }
    
    func loadData() {
        weeklyAnalytics = repository.loadWeeklyAnalytics()
        clearOldData()
        NotificationCenter.default.post(name: .analyticsDidUpdate, object: nil)
    }
    
    private func setupWeeklyReset() {
        // Remove any existing observers first to prevent duplicates
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(checkAndResetWeek),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        // Clean up notification observers to prevent retain cycles
        NotificationCenter.default.removeObserver(self)
        print("🧹 AnalyticsManager deallocated and observers cleaned up")
    }
    
    @objc private func checkAndResetWeek() {
        clearOldData()
        NotificationCenter.default.post(name: .analyticsDidUpdate, object: nil)
    }
    
    func recordProgress(for goal: Goal, entry: GoalEntry) {
        let calendar = Calendar.current
        let weekStart = calendar.startOfWeek()
        
        var analytics = weeklyAnalytics[goal.id] ?? WeeklyAnalytics(
            id: UUID(),
            weekStartDate: weekStart,
            goalId: goal.id,
            dailyData: []
        )
        
        if analytics.dailyData.isEmpty {
            // Initialize the week with the correct target count
            analytics.dailyData = (0..<7).map { day in
                let date = calendar.date(byAdding: .day, value: day, to: weekStart) ?? weekStart
                return DailyProgressData(
                    id: UUID(),
                    date: date,
                    goalId: goal.id,
                    completedCount: 0,
                    targetCount: goal.targetCount,
                    completionTime: []
                )
            }
        }
        
        let today = calendar.startOfDay(for: Date())
        if var dailyData = analytics.dailyData.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            if goal.title == "Meals & Snacks" {
                // For meals, track unique meal types per day
                if entry.completed, let mealTypeStr = entry.mealType {
                    print("📊 Recording meal analytics for: \(mealTypeStr)")
                    
                    // Add completion time regardless
                    var newCompletionTimes = dailyData.completionTime
                    newCompletionTimes.append(entry.timestamp)
                    
                    // Calculate unique meal types for today (we need to track this differently)
                    // For now, let's use a simpler approach: increment count for each meal logged
                    dailyData = DailyProgressData(
                        id: dailyData.id,
                        date: today,
                        goalId: goal.id,
                        completedCount: dailyData.completedCount + 1,
                        targetCount: goal.targetCount,
                        completionTime: newCompletionTimes
                    )
                    print("✅ Meal analytics updated: \(dailyData.completedCount)/\(dailyData.targetCount)")
                }
                
                // Update the analytics with the new daily data
                if let index = analytics.dailyData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                    analytics.dailyData[index] = dailyData
                }
            } else {
                // Existing logic for other goals
                dailyData = DailyProgressData(
                    id: dailyData.id,
                    date: today,
                    goalId: goal.id,
                    completedCount: entry.completed ? dailyData.completedCount + 1 : dailyData.completedCount,
                    targetCount: goal.targetCount,
                    completionTime: {
                        if entry.completed {
                            var times = dailyData.completionTime
                            times.append(entry.timestamp)
                            return times
                        } else {
                            return dailyData.completionTime
                        }
                    }()
                )
                
                if let index = analytics.dailyData.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
                    analytics.dailyData[index] = dailyData
                }
            }
        }
        
        weeklyAnalytics[goal.id] = analytics
        saveData()
        
        NotificationCenter.default.post(name: .analyticsDidUpdate, object: nil)
    }
    
    private func ensureWeeklyData(for analytics: inout WeeklyAnalytics) {
        let calendar = Calendar.current
        let weekStart = calendar.startOfWeek()
        
        // Create array of all days in the week
        let weekDays = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: weekStart) ?? weekStart
        }
        
        // Get the goal's target count
        let targetCount = weeklyAnalytics.values
            .first(where: { $0.goalId == analytics.goalId })?
            .dailyData.first?.targetCount ?? 5 // Default to 5 if not found
        
        // Add missing days
        analytics.dailyData = weekDays.map { date in
            if let existing = analytics.dailyData.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return existing
            } else {
                return DailyProgressData(
                    id: UUID(),
                    date: date,
                    goalId: analytics.goalId,
                    completedCount: 0,
                    targetCount: targetCount,
                    completionTime: []
                )
            }
        }
        
        // Sort by date
        analytics.dailyData.sort { $0.date < $1.date }
    }
    
    private func saveData() {
        repository.saveWeeklyAnalytics(weeklyAnalytics)
    }
    
    func clearOldData() {
        let calendar = Calendar.current
        let currentWeekStart = calendar.startOfWeek()
        
        weeklyAnalytics = weeklyAnalytics.filter { _, analytics in
            analytics.weekStartDate == currentWeekStart
        }
        saveData()
    }
}
