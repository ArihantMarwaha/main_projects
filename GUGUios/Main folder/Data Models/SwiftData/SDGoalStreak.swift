//
//  SDGoalStreak.swift
//  GUGUios
//
//  SwiftData model for GoalStreak persistence
//

import Foundation
import SwiftData

@Model
class SDGoalStreak {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletionDate: Date?
    var totalCompletions: Int
    var perfectWeeks: Int
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship
    var goal: SDGoal?
    
    init(id: UUID = UUID(),
         goalId: UUID,
         currentStreak: Int = 0,
         bestStreak: Int = 0,
         lastCompletionDate: Date? = nil,
         totalCompletions: Int = 0,
         perfectWeeks: Int = 0) {
        self.id = id
        self.goalId = goalId
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastCompletionDate = lastCompletionDate
        self.totalCompletions = totalCompletions
        self.perfectWeeks = perfectWeeks
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    
   
    
    // Update streak information
    func updateStreak(current: Int, best: Int, lastCompletion: Date?, total: Int, perfectWeeks: Int) {
        self.currentStreak = current
        self.bestStreak = best
        self.lastCompletionDate = lastCompletion
        self.totalCompletions = total
        self.perfectWeeks = perfectWeeks
        self.updatedAt = Date()
    }
}
