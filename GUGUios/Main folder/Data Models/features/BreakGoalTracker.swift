//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import Combine

@MainActor
class BreakGoalTracker: GoalTracker {
    static func createDefault(analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) -> BreakGoalTracker {
        let breakGoal = Goal(
            title: "Take Breaks",
            targetCount: 6,
            intervalInSeconds: TrackerConstants.hourInSeconds * 2,
            colorScheme: .green,
            isDefault: true  // Mark as default
        )
        return BreakGoalTracker(goal: breakGoal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
    }
    
    override init(goal: Goal, analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) {
        super.init(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
    }
    
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            // Schedule goal reminder if not fully completed
            let currentProgress = todayEntries.filter { $0.completed }.count
            let remaining = goal.targetCount - currentProgress
            if remaining > 0 {
                NotificationManager.shared.scheduleGoalReminder(
                    goalTitle: goal.title,
                    targetCount: goal.targetCount,
                    currentProgress: currentProgress
                )
            }
            
            // Schedule cooldown end notification
            if let nextAvailable = entry.nextAvailableTime {
                NotificationManager.shared.scheduleGoalCooldownEnd(
                    goalTitle: goal.title,
                    cooldownEndTime: nextAvailable
                )
            }
        }
    }
}






