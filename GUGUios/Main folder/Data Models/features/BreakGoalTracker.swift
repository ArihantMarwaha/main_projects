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
    static func createDefault(analyticsManager: AnalyticsManager) -> BreakGoalTracker {
        let breakGoal = Goal(
            title: "Take Breaks",
            targetCount: 6,
            intervalInSeconds: TrackerConstants.hourInSeconds * 2,
            colorScheme: .green,
            isDefault: true  // Mark as default
        )
        return BreakGoalTracker(goal: breakGoal, analyticsManager: analyticsManager)
    }
    
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            NotificationManager.shared.scheduleNotification(
                title: "Break Time!",
                body: "Time to stretch and rest your eyes",
                delay: 3 * TrackerConstants.hourInSeconds
            )
        }
    }
}






