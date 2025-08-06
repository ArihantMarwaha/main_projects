//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation

struct CustomGoalTemplate: Codable, Identifiable {
    let id: UUID
    var title: String
    var description: String
    var targetCount: Int
    var intervalHours: Double
    var colorScheme: GoalColorScheme
    var isEnabled: Bool
    var hasCustomReminders: Bool
    var reminderTimes: [Date]
    
    init(id: UUID = UUID(),
         title: String = "",
         description: String = "",
         targetCount: Int = 1,
         intervalHours: Double = 1,
         colorScheme: GoalColorScheme = .blue,
         isEnabled: Bool = true,
         hasCustomReminders: Bool = false,
         reminderTimes: [Date] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.intervalHours = intervalHours
        self.colorScheme = colorScheme
        self.isEnabled = isEnabled
        self.hasCustomReminders = hasCustomReminders
        self.reminderTimes = reminderTimes
    }
    
    func createGoal() -> Goal {
        Goal(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            targetCount: targetCount,
            intervalInSeconds: intervalHours * 3600,
            colorScheme: colorScheme,
            hasCustomReminders: hasCustomReminders,
            reminderTimes: reminderTimes
        )
    }
}

