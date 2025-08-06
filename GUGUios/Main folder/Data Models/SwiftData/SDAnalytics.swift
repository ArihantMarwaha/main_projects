//
//  SDAnalytics.swift
//  GUGUios
//
//  SwiftData model for Analytics persistence
//

import Foundation
import SwiftData

@Model
class SDAnalytics {
    @Attribute(.unique) var id: UUID
    var goalId: UUID
    var weekStartDate: Date
    var dailyCompletionData: Data // JSON encoded daily data
    var weeklyCompletionRate: Double
    var totalCompletions: Int
    var averageCompletionTime: TimeInterval?
    var streakCount: Int
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship
    var goal: SDGoal?
    
    init(id: UUID = UUID(),
         goalId: UUID,
         weekStartDate: Date,
         dailyCompletionData: Data = Data(),
         weeklyCompletionRate: Double = 0.0,
         totalCompletions: Int = 0,
         averageCompletionTime: TimeInterval? = nil,
         streakCount: Int = 0) {
        self.id = id
        self.goalId = goalId
        self.weekStartDate = weekStartDate
        self.dailyCompletionData = dailyCompletionData
        self.weeklyCompletionRate = weeklyCompletionRate
        self.totalCompletions = totalCompletions
        self.averageCompletionTime = averageCompletionTime
        self.streakCount = streakCount
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Convert to legacy WeeklyAnalytics model for compatibility
    func toLegacyWeeklyAnalytics() -> WeeklyAnalytics? {
        guard let dailyData = try? JSONDecoder().decode([DailyProgressData].self, from: dailyCompletionData) else {
            return nil
        }
        
        return WeeklyAnalytics(
            id: id,
            weekStartDate: weekStartDate,
            goalId: goalId,
            dailyData: dailyData
        )
    }
    
    // Create from legacy WeeklyAnalytics model
    static func fromLegacyWeeklyAnalytics(_ analytics: WeeklyAnalytics) -> SDAnalytics? {
        guard let encodedData = try? JSONEncoder().encode(analytics.dailyData) else {
            return nil
        }
        
        return SDAnalytics(
            id: analytics.id,
            goalId: analytics.goalId,
            weekStartDate: analytics.weekStartDate,
            dailyCompletionData: encodedData,
            weeklyCompletionRate: analytics.weeklyCompletionRate,
            totalCompletions: analytics.dailyData.reduce(0) { $0 + $1.completedCount },
            averageCompletionTime: analytics.averageCompletionTime
        )
    }
    
    // Helper methods
    func updateDailyData(_ dailyData: [DailyProgressData]) {
        if let encodedData = try? JSONEncoder().encode(dailyData) {
            self.dailyCompletionData = encodedData
            self.totalCompletions = dailyData.reduce(0) { $0 + $1.completedCount }
            self.weeklyCompletionRate = calculateWeeklyCompletionRate(from: dailyData)
            self.updatedAt = Date()
        }
    }
    
    private func calculateWeeklyCompletionRate(from dailyData: [DailyProgressData]) -> Double {
        guard !dailyData.isEmpty else { return 0.0 }
        
        let totalPossible = dailyData.reduce(0) { $0 + $1.targetCount }
        let totalCompleted = dailyData.reduce(0) { $0 + $1.completedCount }
        
        return totalPossible > 0 ? Double(totalCompleted) / Double(totalPossible) : 0.0
    }
    
    var dailyData: [DailyProgressData] {
        (try? JSONDecoder().decode([DailyProgressData].self, from: dailyCompletionData)) ?? []
    }
}