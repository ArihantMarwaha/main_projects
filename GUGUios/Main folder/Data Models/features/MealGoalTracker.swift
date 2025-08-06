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
            case .breakfast: return 3 * 3600 // 3 hours
            case .morningSnack: return 3 * 3600 // 3 hours
            case .lunch: return 3 * 3600 // 3 hours
            case .afternoonSnack: return 3 * 3600 // 3 hours
            case .dinner: return 3 * 3600 // 3 hours
            }
        }
        
    }
    
    @Published private(set) var completedMeals: Set<MealType> = []
    @Published private(set) var cooldowns: [MealType: Date] = [:]
    @Published private(set) var lastMealLogged: MealType?
    
    static func createDefault(analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) -> MealGoalTracker {
        let mealGoal = Goal(
            title: "Meals & Snacks",
            targetCount: 5,
            intervalInSeconds: TrackerConstants.hourInSeconds * 3, // 3 hours
            colorScheme: .orange,
            isDefault: true
        )
        return MealGoalTracker(goal: mealGoal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
    }
    
    override func getProgress() -> Double {
        Double(completedMeals.count) / Double(goal.targetCount)
    }
    
    override func loadSavedData() {
        print("🔄 MealGoalTracker: Starting loadSavedData()")
        super.loadSavedData()
        
        loadCooldowns()
        resetExpiredCooldowns()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter and validate entries more strictly
        let todayCompletedEntries = todayEntries
            .filter { entry in
                // Check if entry is for today and completed
                let isToday = calendar.isDate(entry.timestamp, inSameDayAs: today)
                let isCompleted = entry.completed
                let hasMealType = entry.mealType != nil
                
                print("   🔍 Entry ID: \(entry.id.uuidString.prefix(8)) - MealType: \(entry.mealType ?? "nil") - completed: \(isCompleted), isToday: \(isToday), hasMealType: \(hasMealType)")
                
                return isCompleted && isToday && hasMealType
            }
        
        print("📊 Found \(todayCompletedEntries.count) valid completed entries for today:")
        todayCompletedEntries.forEach { entry in
            print("   - Entry: \(entry.mealType!) at \(entry.timestamp) (ID: \(entry.id.uuidString.prefix(8)))")
        }
        
        let newCompletedMeals = Set(
            todayCompletedEntries
                .compactMap { (entry: GoalEntry) -> MealType? in
                    guard let mealTypeString = entry.mealType else { 
                        print("   ⚠️ Entry has nil mealType")
                        return nil 
                    }
                    let mealType = MealType(rawValue: mealTypeString)
                    if mealType == nil {
                        print("   ❌ Could not convert '\(mealTypeString)' to MealType")
                        print("   📝 Available MealTypes: \(MealType.allCases.map { $0.rawValue })")
                    } else {
                        print("   ✅ Successfully converted '\(mealTypeString)' to MealType")
                    }
                    return mealType
                }
        )
        
        completedMeals = newCompletedMeals
        
        print("📊 Final loaded meal data: \(completedMeals.count) completed meals today")
        completedMeals.forEach { meal in
            print("   ✅ Completed: \(meal.rawValue)")
        }
        
        // Force UI update (already on MainActor)
        objectWillChange.send()
    }
    
    private func resetExpiredCooldowns() {
        let now = Date()
        let expiredCooldowns = cooldowns.filter { _, endTime in
            now >= endTime
        }
        
        for (mealType, _) in expiredCooldowns {
            cooldowns.removeValue(forKey: mealType)
            print("🕒 Removed expired cooldown for \(mealType.rawValue)")
        }
        
        if !expiredCooldowns.isEmpty {
            saveCooldowns()
        }
    }
    
    func canLogMeal(_ type: MealType) -> Bool {
        print("🔍 Checking if can log \(type.rawValue):")
        print("   - Already completed: \(completedMeals.contains(type))")
        
        // Can't log if already completed
        guard !completedMeals.contains(type) else { 
            print("   ❌ Already completed")
            return false 
        }
        
        // Check cooldown for this meal type
        if let cooldownEnd = cooldowns[type] {
            let canLog = Date() >= cooldownEnd
            print("   - Cooldown end: \(cooldownEnd)")
            print("   - Current time: \(Date())")
            print("   - Can log: \(canLog)")
            return canLog
        }
        
        print("   ✅ No cooldown, can log")
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
        
        print("🍽️ Logging meal: \(type.rawValue)")
        
        // Update UI state immediately (safe operations only)
        withAnimation(.spring(response: 0.3)) {
            completedMeals.insert(type)
            cooldowns[type] = nextAvailableTime
            lastMealLogged = type
            todayEntries.append(entry)
            objectWillChange.send()
        }
        
        // Perform data operations asynchronously to prevent UI hangs
        Task {
            do {
                // Save cooldowns first (safer operation)
                await MainActor.run { [weak self] in
                    self?.saveCooldowns()
                }
                
                // Update analytics 
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.analyticsManager.recordProgress(for: self.goal, entry: entry)
                }
                
                // Save entries to SwiftData
                await MainActor.run { [weak self] in
                    self?.saveEntries()
                }
                
                // Post simplified notification (avoid passing complex objects)
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .goalProgressUpdated,
                        object: nil,
                        userInfo: [
                            "goalId": goal.id.uuidString,
                            "goalTitle": goal.title,
                            "mealType": type.rawValue,
                            "completed": true
                        ]
                    )
                    
                    print("✅ Meal logged successfully: \(type.rawValue)")
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Error during meal logging: \(error.localizedDescription)")
                    // Don't crash - the UI state is already updated
                }
            }
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
        
        let filteredEntries: [GoalEntry] = todayEntries
            .filter { entry in
                entry.completed &&
                calendar.isDate(entry.timestamp, inSameDayAs: today)
            }
        
        let completedToday: [MealType] = filteredEntries
            .compactMap { (entry: GoalEntry) -> MealType? in
                guard let mealTypeString = entry.mealType else { return nil }
                return MealType(rawValue: mealTypeString)
            }
        
        print("🍽️ Today's completed meals: \(completedToday.map { $0.rawValue })")
        return completedToday
    }
    
    // Override to properly record analytics and schedule notifications
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            // Schedule goal reminder if not fully completed
            let remaining = goal.targetCount - getDailyProgress()
            if remaining > 0 {
                NotificationManager.shared.scheduleGoalReminder(
                    goalTitle: goal.title,
                    targetCount: goal.targetCount,
                    currentProgress: getDailyProgress()
                )
            }
            
            // Schedule cooldown end notification if meal type provided
            if let mealTypeString = entry.mealType,
               let mealType = MealType(rawValue: mealTypeString),
               let cooldownEnd = getCooldownEndTime(for: mealType) {
                NotificationManager.shared.scheduleGoalCooldownEnd(
                    goalTitle: "\(goal.title) - \(mealType.rawValue)",
                    cooldownEndTime: cooldownEnd
                )
            }
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
                .compactMap { (entry: GoalEntry) -> MealType? in
                    guard let mealTypeString = entry.mealType else { return nil }
                    return MealType(rawValue: mealTypeString)
                }
        )
    }
    
    // Save cooldowns dictionary to UserDefaults
    private func saveCooldowns() {
        do {
            let defaults = UserDefaults.standard
            let dictToSave = cooldowns.reduce(into: [String: Date]()) { partialResult, pair in
                partialResult[pair.key.rawValue] = pair.value
            }
            defaults.set(dictToSave, forKey: "Cooldowns-\(goal.id.uuidString)")
            print("💾 Saved cooldowns for \(cooldowns.count) meal types")
        } catch {
            print("❌ Failed to save cooldowns: \(error.localizedDescription)")
        }
    }
    
    // Load cooldowns dictionary from UserDefaults
    private func loadCooldowns() {
        let defaults = UserDefaults.standard
        guard let savedDict = defaults.dictionary(forKey: "Cooldowns-\(goal.id.uuidString)") as? [String: Date] else {
            cooldowns = [:]
            return
        }
        // Convert string keys back to MealType keys
        var newCooldowns: [MealType: Date] = [:]
        for (stringKey, date) in savedDict {
            if let mealType = MealType(rawValue: stringKey) {
                newCooldowns[mealType] = date
            }
        }
        cooldowns = newCooldowns
    }
}

