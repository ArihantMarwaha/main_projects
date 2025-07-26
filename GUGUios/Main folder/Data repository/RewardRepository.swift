//
//  RewardRepository.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import Foundation

@MainActor
class RewardRepository {
    private let STREAKS_KEY = "GOAL_STREAKS_KEY"
    private let ACHIEVEMENTS_KEY = "ACHIEVEMENTS_KEY"
    private let CRITERIA_KEY = "ACHIEVEMENT_CRITERIA_KEY"
    
    // Load and save streaks
    func saveStreaks(_ streaks: [UUID: GoalStreak]) {
        if let encoded = try? JSONEncoder().encode(streaks) {
            UserDefaults.standard.set(encoded, forKey: STREAKS_KEY)
        }
    }
    
    func loadStreaks() -> [UUID: GoalStreak] {
        guard let data = UserDefaults.standard.data(forKey: STREAKS_KEY),
              let decoded = try? JSONDecoder().decode([UUID: GoalStreak].self, from: data)
        else {
            return [:]
        }
        return decoded
    }
    
    // Load and save achievements
    func saveAchievements(_ achievements: [Achievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: ACHIEVEMENTS_KEY)
        }
    }
    
    func loadAchievements() -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: ACHIEVEMENTS_KEY),
              let decoded = try? JSONDecoder().decode([Achievement].self, from: data)
        else {
            return []
        }
        return decoded
    }
    
    // Achievement criteria management
    func saveCriteria(_ criteria: [AchievementCriteria]) {
        if let encoded = try? JSONEncoder().encode(criteria) {
            UserDefaults.standard.set(encoded, forKey: CRITERIA_KEY)
        }
    }
    
    func loadCriteria() -> [AchievementCriteria] {
        guard let data = UserDefaults.standard.data(forKey: CRITERIA_KEY),
              let decoded = try? JSONDecoder().decode([AchievementCriteria].self, from: data)
        else {
            return defaultCriteria()
        }
        return decoded
    }
    
    private func defaultCriteria() -> [AchievementCriteria] {
        return [
            // Water Streak Achievements
            AchievementCriteria(type: .waterStreak, level: .bronze, requiredCount: 3,
                               description: "Maintain water intake for 3 days"),
            AchievementCriteria(type: .waterStreak, level: .silver, requiredCount: 7,
                               description: "Maintain water intake for a week"),
            AchievementCriteria(type: .waterStreak, level: .gold, requiredCount: 14,
                               description: "Maintain water intake for 2 weeks"),
            
            // Meal Streak Achievements
            AchievementCriteria(type: .mealStreak, level: .bronze, requiredCount: 3,
                               description: "Regular meals for 3 days"),
            AchievementCriteria(type: .mealStreak, level: .silver, requiredCount: 7,
                               description: "Regular meals for a week"),
            AchievementCriteria(type: .mealStreak, level: .gold, requiredCount: 14,
                               description: "Regular meals for 2 weeks"),
            
            // Break Streak Achievements
            AchievementCriteria(type: .breakStreak, level: .bronze, requiredCount: 3,
                               description: "Take breaks for 3 days"),
            AchievementCriteria(type: .breakStreak, level: .silver, requiredCount: 7,
                               description: "Take breaks for a week"),
            AchievementCriteria(type: .breakStreak, level: .gold, requiredCount: 14,
                               description: "Take breaks for 2 weeks"),
            
            // Perfect Day/Week Achievements
            AchievementCriteria(type: .perfectDay, level: .silver, requiredCount: 1,
                               description: "Complete all daily goals"),
            AchievementCriteria(type: .perfectWeek, level: .gold, requiredCount: 1,
                               description: "Complete all goals for a week"),
            
            // Pet Care Achievements
            AchievementCriteria(type: .petCare, level: .bronze, requiredCount: 3,
                               description: "Keep pet happy for 3 days"),
            AchievementCriteria(type: .petCare, level: .silver, requiredCount: 7,
                               description: "Keep pet happy for a week"),
            
            // Consistency Achievements
            AchievementCriteria(type: .consistency, level: .bronze, requiredCount: 5,
                               description: "Maintain daily routine for 5 days"),
            AchievementCriteria(type: .consistency, level: .silver, requiredCount: 10,
                               description: "Maintain daily routine for 10 days"),
            AchievementCriteria(type: .consistency, level: .gold, requiredCount: 30,
                               description: "Maintain daily routine for a month")
        ]
    }
}
