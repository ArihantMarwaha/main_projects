//
//  SDGoalEntry.swift
//  GUGUios
//
//  SwiftData model for GoalEntry persistence
//

import Foundation
import SwiftData

@Model
class SDGoalEntry {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var timestamp: Date
    var completed: Bool
    var scheduledTime: Date
    var nextAvailableTime: Date?
    var mealType: String?
    var createdAt: Date
    
    @Relationship
    var goal: SDGoal?
    
    init(id: UUID = UUID(),
         goalId: UUID,
         timestamp: Date = Date(),
         completed: Bool = false,
         scheduledTime: Date,
         nextAvailableTime: Date? = nil,
         mealType: String? = nil) {
        self.id = id
        self.goalId = goalId
        self.timestamp = timestamp
        self.completed = completed
        self.scheduledTime = scheduledTime
        self.nextAvailableTime = nextAvailableTime
        self.mealType = mealType
        self.createdAt = Date()
    }
    
    // Convert to legacy GoalEntry model for compatibility
    func toLegacyGoalEntry() -> GoalEntry {
        return GoalEntry(
            id: id,
            goalId: goalId,
            timestamp: timestamp,
            completed: completed,
            scheduledTime: scheduledTime,
            nextAvailableTime: nextAvailableTime,
            mealType: mealType
        )
    }
    
    // Create from legacy GoalEntry model with validation
    static func fromLegacyGoalEntry(_ entry: GoalEntry) -> SDGoalEntry {
        // Validate that we have valid IDs
        guard !entry.id.uuidString.isEmpty,
              !entry.goalId.uuidString.isEmpty else {
            print("⚠️ Invalid entry IDs detected, generating new ID")
            return SDGoalEntry(
                id: UUID(), // Generate new ID if invalid
                goalId: entry.goalId,
                timestamp: entry.timestamp,
                completed: entry.completed,
                scheduledTime: entry.scheduledTime,
                nextAvailableTime: entry.nextAvailableTime,
                mealType: entry.mealType
            )
        }
        
        // Validate dates to prevent corruption
        let validatedTimestamp = validateDate(entry.timestamp)
        let validatedScheduledTime = validateDate(entry.scheduledTime)
        let validatedNextAvailableTime = entry.nextAvailableTime.map { validateDate($0) }
        
        return SDGoalEntry(
            id: entry.id,
            goalId: entry.goalId,
            timestamp: validatedTimestamp,
            completed: entry.completed,
            scheduledTime: validatedScheduledTime,
            nextAvailableTime: validatedNextAvailableTime,
            mealType: validateMealType(entry.mealType)
        )
    }
    
    // Helper validation methods
    private static func validateDate(_ date: Date) -> Date {
        // Ensure date is within reasonable bounds (not too far in past/future)
        let now = Date()
        let maxPastDate = Calendar.current.date(byAdding: .year, value: -1, to: now) ?? now
        let maxFutureDate = Calendar.current.date(byAdding: .year, value: 1, to: now) ?? now
        
        if date < maxPastDate {
            print("⚠️ Date too far in past, using max past date")
            return maxPastDate
        } else if date > maxFutureDate {
            print("⚠️ Date too far in future, using max future date")
            return maxFutureDate
        }
        
        return date
    }
    
    private static func validateMealType(_ mealType: String?) -> String? {
        guard let mealType = mealType else { return nil }
        
        // Validate meal type against actual MealGoalTracker values
        let validMealTypes = ["Breakfast", "Morning Snack", "Lunch", "Afternoon Snack", "Dinner"]
        if validMealTypes.contains(mealType) {
            return mealType
        }
        
        print("⚠️ Invalid meal type '\(mealType)' detected during save - this will cause data loss!")
        print("⚠️ Valid meal types are: \(validMealTypes)")
        return mealType // Return original to preserve data instead of corrupting it
    }
    
    // Helper computed properties
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledTime)
    }
    
    var isOverdue: Bool {
        !completed && Date() > scheduledTime
    }
}