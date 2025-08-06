//
//  SDGoal.swift
//  GUGUios
//
//  SwiftData model for Goal persistence
//

import Foundation
import SwiftData
import SwiftUI

@Model
class SDGoal {
    @Attribute(.unique) var id: UUID
    var title: String
    var goalDescription: String
    var targetCount: Int
    var intervalInSeconds: TimeInterval
    var colorSchemeRawValue: String
    var startTime: Date
    var isActive: Bool
    var isDefault: Bool
    var requiresSpecialInterface: Bool = false
    var hasCustomReminders: Bool = false
    var reminderTimes: [Date] = []
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \SDGoalEntry.goal)
    var entries: [SDGoalEntry] = []
    
    @Relationship(deleteRule: .cascade, inverse: \SDAnalytics.goal)
    var analytics: [SDAnalytics] = []
    
    init(id: UUID = UUID(),
         title: String,
         description: String = "",
         targetCount: Int,
         intervalInSeconds: TimeInterval,
         colorScheme: GoalColorScheme = .blue,
         startTime: Date = Date(),
         isActive: Bool = true,
         isDefault: Bool = false,
         requiresSpecialInterface: Bool = false,
         hasCustomReminders: Bool = false,
         reminderTimes: [Date] = []) {
        self.id = id
        self.title = title
        self.goalDescription = description
        self.targetCount = targetCount
        self.intervalInSeconds = intervalInSeconds
        self.colorSchemeRawValue = colorScheme.rawValue
        self.startTime = startTime
        self.isActive = isActive
        self.isDefault = isDefault
        self.requiresSpecialInterface = requiresSpecialInterface
        self.hasCustomReminders = hasCustomReminders
        self.reminderTimes = reminderTimes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Convert to legacy Goal model for compatibility
    func toLegacyGoal() -> Goal {
        return Goal(
            id: id,
            title: title,
            description: goalDescription,
            targetCount: targetCount,
            intervalInSeconds: intervalInSeconds,
            colorScheme: GoalColorScheme(rawValue: colorSchemeRawValue) ?? .blue,
            startTime: startTime,
            isActive: isActive,
            isDefault: isDefault,
            requiresSpecialInterface: requiresSpecialInterface,
            hasCustomReminders: hasCustomReminders,
            reminderTimes: reminderTimes
        )
    }
    
    // Create from legacy Goal model
    static func fromLegacyGoal(_ goal: Goal) -> SDGoal {
        return SDGoal(
            id: goal.id,
            title: goal.title,
            description: goal.description,
            targetCount: goal.targetCount,
            intervalInSeconds: goal.intervalInSeconds,
            colorScheme: goal.colorScheme,
            startTime: goal.startTime,
            isActive: goal.isActive,
            isDefault: goal.isDefault,
            requiresSpecialInterface: goal.requiresSpecialInterface,
            hasCustomReminders: goal.hasCustomReminders,
            reminderTimes: goal.reminderTimes
        )
    }
    
    var colorScheme: GoalColorScheme {
        GoalColorScheme(rawValue: colorSchemeRawValue) ?? .blue
    }
    
    var color: Color {
        colorScheme.primary
    }
    
    var sortOrder: Int {
        isDefault ? 0 : 1
    }
}