//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MealGoalTracker: GoalTracker {
    enum MealType: String, CaseIterable, Codable {
        case breakfast = "Breakfast"
        case morningSnack = "Morning Snack"
        case lunch = "Lunch"
        case afternoonSnack = "Afternoon Snack"
        case dinner = "Dinner"
        
        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .morningSnack: return "cup.and.saucer.fill"
            case .lunch: return "sun.max.fill"
            case .afternoonSnack: return "leaf.fill"
            case .dinner: return "moon.stars.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .breakfast: return .orange
            case .morningSnack: return .blue
            case .lunch: return .red
            case .afternoonSnack: return .green
            case .dinner: return .purple
            }
        }
        
        var cooldownInterval: TimeInterval {
            switch self {
            case .breakfast: return 2 * 3600 // 2 hours
            case .morningSnack: return 1.5 * 3600 // 1.5 hours
            case .lunch: return 2 * 3600 // 2 hours
            case .afternoonSnack: return 1.5 * 3600 // 1.5 hours
            case .dinner: return 2 * 3600 // 2 hours
            }
        }
    }
    
    @Published private(set) var completedMeals: Set<MealType> = []
    @Published private(set) var cooldowns: [MealType: Date] = [:]
    @Published private(set) var lastMealLogged: MealType?
    
    static func createDefault(analyticsManager: AnalyticsManager) -> MealGoalTracker {
        let mealGoal = Goal(
            title: "Meals & Snacks",
            targetCount: 5,
            intervalInSeconds: TrackerConstants.hourInSeconds * 2,
            colorScheme: .orange,
            isDefault: true
        )
        return MealGoalTracker(goal: mealGoal, analyticsManager: analyticsManager)
    }
    
    override func getProgress() -> Double {
        Double(completedMeals.count) / Double(goal.targetCount)
    }
    
    override func loadSavedData() {
        super.loadSavedData()
        
        loadCooldowns()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Restore completed meals from entries
        completedMeals = Set(
            todayEntries
                .filter { entry in
                    entry.completed && calendar.isDate(entry.timestamp, inSameDayAs: today)
                }
                .compactMap { entry in
                    guard let mealTypeString = entry.mealType else { return nil }
                    return MealType(rawValue: mealTypeString)
                }
        )
        
        // Update analytics for each completed meal
        for entry in todayEntries where entry.completed && calendar.isDate(entry.timestamp, inSameDayAs: today) {
            analyticsManager.recordProgress(for: goal, entry: entry)
        }
    }
    
    func canLogMeal(_ type: MealType) -> Bool {
        // Can't log if already completed
        guard !completedMeals.contains(type) else { return false }
        
        // Check cooldown for this meal type
        if let cooldownEnd = cooldowns[type] {
            return Date() >= cooldownEnd
        }
        
        return true
    }
    
    func logMeal(_ type: MealType) {
        guard canLogMeal(type) else { return }
        
        let now = Date()
        let nextAvailableTime = now.addingTimeInterval(type.cooldownInterval)
        
        // Create a completed entry for this meal
        let entry = GoalEntry(
            goalId: goal.id,
            timestamp: now,
            completed: true,
            scheduledTime: now,
            nextAvailableTime: nextAvailableTime,
            mealType: type.rawValue
        )
        
        // Batch UI updates
        withAnimation(.spring(response: 0.3)) {
            completedMeals.insert(type)
            cooldowns[type] = nextAvailableTime
            saveCooldowns()
            lastMealLogged = type
            todayEntries.append(entry)
            
            // Update analytics with the completed meal
            analyticsManager.recordProgress(for: goal, entry: entry)
            
            // Save after all updates
            saveEntries()
            
            // Notify of progress update
            NotificationCenter.default.post(
                name: .goalProgressUpdated,
                object: nil,
                userInfo: [
                    "goal": goal,
                    "entry": entry,
                    "goalType": goal.title,
                    "mealType": type.rawValue,
                    "cooldownDuration": type.cooldownInterval,
                    "cooldownEndTime": nextAvailableTime,
                    "goalId": goal.id
                ]
            )
            
            objectWillChange.send()
        }
    }
    
    func isCompleted(_ type: MealType) -> Bool {
        completedMeals.contains(type)
    }
    
    func isCoolingDown(_ type: MealType) -> Bool {
        guard let cooldownEnd = cooldowns[type] else { return false }
        return Date() < cooldownEnd && !isCompleted(type)
    }
    
    func getCooldownEndTime(for mealType: MealType) -> Date? {
        cooldowns[mealType]
    }
    
    func getLastMealLogged() -> MealType? {
        lastMealLogged
    }
    
    // Add new function to get today's completed meals
    func getTodayCompletedMeals() -> [MealType] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return todayEntries
            .filter { entry in
                entry.completed &&
                calendar.isDate(entry.timestamp, inSameDayAs: today)
            }
            .compactMap { entry in
                guard let mealTypeString = entry.mealType else { return nil }
                return MealType(rawValue: mealTypeString)
            }
    }
    
    // Override to properly record analytics
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            NotificationManager.shared.scheduleNotification(
                title: "Time for your next meal!",
                body: "Stay on track with your meal schedule",
                delay: TrackerConstants.hourInSeconds * 2
            )
        }
    }
    
    // Add function to get meal-specific progress
    func getMealProgress(for mealType: MealType) -> Bool {
        completedMeals.contains(mealType)
    }
    
    // Add function to get remaining meals
    func getRemainingMeals() -> [MealType] {
        MealType.allCases.filter { !completedMeals.contains($0) }
    }
    
    // Add this method to properly calculate daily progress
    func getDailyProgress() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return todayEntries
            .filter { entry in
                entry.completed && calendar.isDate(entry.timestamp, inSameDayAs: today)
            }
            .count
    }
    
    // Add this method to get meal progress for a specific date
    func getMealProgress(for mealType: MealType, on date: Date) -> Bool {
        let calendar = Calendar.current
        return todayEntries
            .filter { entry in
                entry.completed &&
                calendar.isDate(entry.timestamp, inSameDayAs: date) &&
                entry.mealType == mealType.rawValue
            }
            .count > 0
    }
    
    // Add this method to get all completed meals for a specific date
    func getCompletedMeals(for date: Date) -> Set<MealType> {
        let calendar = Calendar.current
        return Set(
            todayEntries
                .filter { entry in
                    entry.completed &&
                    calendar.isDate(entry.timestamp, inSameDayAs: date)
                }
                .compactMap { entry in
                    guard let mealTypeString = entry.mealType else { return nil }
                    return MealType(rawValue: mealTypeString)
                }
        )
    }
    
    // Save cooldowns dictionary to UserDefaults
    private func saveCooldowns() {
        let defaults = UserDefaults.standard
        let dictToSave = cooldowns.reduce(into: [String: Date]()) { partialResult, pair in
            partialResult[pair.key.rawValue] = pair.value
        }
        defaults.set(dictToSave, forKey: "Cooldowns-\(goal.id.uuidString)")
    }
    
    // Load cooldowns dictionary from UserDefaults
    private func loadCooldowns() {
        let defaults = UserDefaults.standard
        guard let savedDict = defaults.dictionary(forKey: "Cooldowns-\(goal.id.uuidString)") as? [String: Date] else {
            cooldowns = [:]
            return
        }
        cooldowns = savedDict.compactMapKeys { MealType(rawValue: $0) }
    }
}

private extension Dictionary {
    /// Returns a dictionary containing the keys and values that can be mapped by the transform,
    /// filtering out nil keys or values.
    func compactMapKeys<K: Hashable>(_ transform: (Key) -> K?) -> [K: Value] {
        var result = [K: Value]()
        for (key, value) in self {
            if let newKey = transform(key) {
                result[newKey] = value
            }
        }
        return result
    }
}
