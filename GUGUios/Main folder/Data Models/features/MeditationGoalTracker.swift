import Foundation
import SwiftUI
import Combine

@MainActor
class MeditationGoalTracker: GoalTracker {
    @Published private(set) var totalSessionsToday: Int = 0
    
    static func createDefault(analyticsManager: AnalyticsManager) -> MeditationGoalTracker {
        let meditationGoal = Goal(
            title: "Daily Meditation",
            description: "Take time to meditate and reflect",
            targetCount: 1,
            intervalInSeconds: TrackerConstants.dayInSeconds, // Once per day
            colorScheme: .purple,
            isDefault: true
        )
        return MeditationGoalTracker(goal: meditationGoal, analyticsManager: analyticsManager)
    }
    
    override func loadSavedData() {
        super.loadSavedData()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Count total sessions for today
        totalSessionsToday = todayEntries.filter { entry in
            entry.completed && calendar.isDate(entry.timestamp, inSameDayAs: today)
        }.count
    }
    
    func logMeditationSession(duration: TimeInterval) {
        let completedEntry = GoalEntry(
            goalId: goal.id,
            timestamp: Date(),
            completed: true,
            scheduledTime: Date(),
            nextAvailableTime: nil,
            mealType: nil
        )
        
        todayEntries.append(completedEntry)
        totalSessionsToday += 1
        
        // Update analytics
        analyticsManager.recordProgress(for: goal, entry: completedEntry)
        
        // Save entries
        saveEntries()
        
        // Schedule next reminder
        Task {
            if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) {
                NotificationManager.shared.scheduleNotification(
                    title: "Time to Meditate",
                    body: "Take a moment to find your inner peace",
                    delay: tomorrow.timeIntervalSinceNow
                )
            }
        }
        
        objectWillChange.send()
    }
    
    override func canLogEntry() -> Bool {
        return goal.isActive // Always allow meditation if goal is active
    }
} 
