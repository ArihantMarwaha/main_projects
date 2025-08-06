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
            isDefault: true,
            requiresSpecialInterface: true
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
        // Find the next incomplete entry to mark as completed
        if let nextEntry = todayEntries.first(where: { !$0.completed }) {
            // Use the existing entry structure but mark it complete
            let completedEntry = GoalEntry(
                id: nextEntry.id, // Use the existing entry's ID
                goalId: goal.id,
                timestamp: Date(),
                completed: true,
                scheduledTime: nextEntry.scheduledTime,
                nextAvailableTime: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                mealType: nil
            )
            
            // Update the entry in the array
            if let index = todayEntries.firstIndex(where: { $0.id == nextEntry.id }) {
                todayEntries[index] = completedEntry
            }
        } else {
            // Create a new entry if none exists
            let completedEntry = GoalEntry(
                goalId: goal.id,
                timestamp: Date(),
                completed: true,
                scheduledTime: Date(),
                nextAvailableTime: Calendar.current.date(byAdding: .day, value: 1, to: Date()),
                mealType: nil
            )
            todayEntries.append(completedEntry)
        }
        
        totalSessionsToday += 1
        
        // Update analytics with proper goal integration
        if let completedEntry = todayEntries.first(where: { $0.completed }) {
            analyticsManager.recordProgress(for: goal, entry: completedEntry)
        }
        
        // Save entries
        saveEntries()
        
        // Post goal progress notification
        NotificationCenter.default.post(
            name: .goalProgressUpdated,
            object: nil,
            userInfo: [
                "goalId": goal.id.uuidString,
                "goalTitle": goal.title,
                "completed": true,
                "duration": duration
            ]
        )
        
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
        print("✅ Meditation session logged: \(Int(duration/60)) minutes")
    }
    
    override func canLogEntry() -> Bool {
        // Meditation goals cannot be logged via quick drag-and-log
        // They must be completed through the meditation timer interface
        print("🧘 Meditation goals require special interface - use meditation timer")
        return false
    }
    
    func canStartMeditationSession() -> Bool {
        // Goal must be active first
        guard goal.isActive else { return false }
        
        // Check if goal is already at 100% completion (for meditation, usually 1 session per day)
        let completedCount = todayEntries.filter { $0.completed }.count
        if completedCount >= goal.targetCount {
            print("🧘 Daily meditation already completed")
            return false
        }
        
        return true
    }
} 
