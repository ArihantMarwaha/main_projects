//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation

struct GoalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let goalId: UUID
    let timestamp: Date
    let completed: Bool
    let scheduledTime: Date
    let nextAvailableTime: Date?
    let mealType: String?
    
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
    }
    
    // Add Equatable conformance
    static func == (lhs: GoalEntry, rhs: GoalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.goalId == rhs.goalId &&
        lhs.timestamp == rhs.timestamp &&
        lhs.completed == rhs.completed &&
        lhs.scheduledTime == rhs.scheduledTime &&
        lhs.nextAvailableTime == rhs.nextAvailableTime &&
        lhs.mealType == rhs.mealType
    }
}
