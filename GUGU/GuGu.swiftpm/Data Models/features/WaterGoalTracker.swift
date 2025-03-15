//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import SwiftUI

@MainActor
class WaterGoalTracker: GoalTracker {
    static func createDefault(analyticsManager: AnalyticsManager) -> WaterGoalTracker {
        let waterGoal = Goal(
            title: "Water Intake",
            targetCount: 8,
            intervalInSeconds: TrackerConstants.hourInSeconds * 2,
            colorScheme: .blue,
            isDefault: true
        )
        return WaterGoalTracker(goal: waterGoal, analyticsManager: analyticsManager)
    }
    
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            NotificationManager.shared.scheduleNotification(
                title: "Water Reminder",
                body: "Time for your next glass of water!",
                delay: TrackerConstants.hourInSeconds
            )
        }
    }
}


