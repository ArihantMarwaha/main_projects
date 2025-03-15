//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 22/01/25.
//

import Foundation

class GoalRepository {
    private let GOALS_KEY = "GOALS_KEY"
    private let ENTRIES_KEY = "ENTRIES_KEY"
    private let LAST_RESET_KEY = "LAST_RESET_KEY"
    
    func saveGoals(_ goals: [Goal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: GOALS_KEY)
        }
    }
    
    func loadGoals() -> [Goal] {
        guard let data = UserDefaults.standard.data(forKey: GOALS_KEY),
              let decoded = try? JSONDecoder().decode([Goal].self, from: data)
        else {
            return []
        }
        // Sort goals by sortOrder before returning
        return decoded.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    func saveEntries(_ entries: [GoalEntry], forGoal goalId: UUID) {
        let key = "\(ENTRIES_KEY)_\(goalId.uuidString)"
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func loadEntries(forGoal goalId: UUID) -> [GoalEntry] {
        // Check if we need to reset before loading entries
        if shouldResetDailyData() {
            // Clear entries and return empty array to trigger new schedule generation
            clearEntries(forGoal: goalId)
            return []
        }
        
        let key = "\(ENTRIES_KEY)_\(goalId.uuidString)"
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([GoalEntry].self, from: data)
        else {
            return []
        }
        
        // Filter out entries from previous days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayEntries = decoded.filter { calendar.isDate($0.scheduledTime, inSameDayAs: today) }
        
        // If we have no entries for today, return empty array to trigger new schedule
        if todayEntries.isEmpty {
            return []
        }
        
        return todayEntries
    }
    
    func clearEntries(forGoal goalId: UUID) {
        let key = "\(ENTRIES_KEY)_\(goalId.uuidString)"
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    private func shouldResetDailyData() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        
        if let lastReset = UserDefaults.standard.object(forKey: LAST_RESET_KEY) as? Date {
            if lastReset < startOfToday {
                // Update last reset time to today
                UserDefaults.standard.set(startOfToday, forKey: LAST_RESET_KEY)
                return true
            }
            return false
        } else {
            // First time running app
            UserDefaults.standard.set(startOfToday, forKey: LAST_RESET_KEY)
            return true
        }
    }
    
    private func clearAllEntries() {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys
        
        // Clear all entry keys
        for key in allKeys where key.hasPrefix("\(ENTRIES_KEY)_") {
            defaults.removeObject(forKey: key)
        }
    }
}

