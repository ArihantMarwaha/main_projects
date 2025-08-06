//
//  AppIntentsManager.swift
//  GUGUios
//
//  Manager for handling App Intents business logic
//

import Foundation
import SwiftData
import AppIntents

@MainActor
class AppIntentsManager {
    static let shared = AppIntentsManager()
    
    private var goalsManager: GoalsManager?
    private var petActivityManager: PetActivityManager?
    
    private init() {}
    
    // MARK: - Setup
    
    func setup(goalsManager: GoalsManager, petActivityManager: PetActivityManager) {
        self.goalsManager = goalsManager
        self.petActivityManager = petActivityManager
        
        // Donate common intents to help Siri learn user patterns
        AppIntentsDonationHelper.shared.donateCommonIntents()
    }
    
    // MARK: - Goal Entity Queries (Removed - using simplified approach)
    
    // MARK: - Goal Logging
    
    func logGoal(goalId: UUID, amount: Int = 1) async -> Bool {
        guard let goalsManager = goalsManager else { 
            print("⚠️ GoalsManager not available in AppIntentsManager")
            return false 
        }
        
        let result = await MainActor.run {
            guard let tracker = goalsManager.trackers[goalId] else { return false }
            
            // Check if we can log entries
            guard tracker.canLogEntry() else { return false }
            
            // Find next available entry to log
            let nextEntry = tracker.todayEntries.first { !$0.completed }
            guard let entry = nextEntry else { return false }
            
            // Log the entry
            tracker.logEntry(for: entry)
            
            // Log additional entries if amount > 1 and possible
            if amount > 1 {
                for _ in 1..<amount {
                    if let nextEntry = tracker.todayEntries.first(where: { !$0.completed }),
                       tracker.canLogEntry() {
                        tracker.logEntry(for: nextEntry)
                    } else {
                        break
                    }
                }
            }
            
            return true
        }
        
        if result {
            AppIntentsAnalytics.shared.trackIntentUsage("LogGoalIntent")
        }
        
        return result
    }
    
    func logWater(amount: Int = 1) async -> Bool {
        guard let goalsManager = goalsManager else { 
            print("⚠️ GoalsManager not available for water logging")
            return false 
        }
        
        let result = await MainActor.run {
            // Find water goal
            guard let waterGoal = goalsManager.goals.first(where: { $0.title == "Water Intake" }),
                  let tracker = goalsManager.trackers[waterGoal.id] else { return false }
            
            return logGoalEntries(tracker: tracker, amount: amount)
        }
        
        if result {
            AppIntentsAnalytics.shared.trackIntentUsage("LogWaterIntent")
        }
        
        return result
    }
    
    func logMeal(type: String) async -> Bool {
        guard let goalsManager = goalsManager else { 
            print("⚠️ GoalsManager not available for meal logging")
            return false 
        }
        
        return await MainActor.run {
            // Find meal goal
            guard let mealGoal = goalsManager.goals.first(where: { $0.title == "Meals & Snacks" }),
                  let mealTracker = goalsManager.trackers[mealGoal.id] as? MealGoalTracker else { return false }
            
            // Convert string to MealType
            guard let mealType = MealGoalTracker.MealType(rawValue: type) else { return false }
            
            // Check if this meal can be logged
            guard mealTracker.canLogMeal(mealType) else { return false }
            
            // Log the meal
            mealTracker.logMeal(mealType)
            return true
        }
    }
    
    func logBreak(duration: Int = 5) async -> Bool {
        guard let goalsManager = goalsManager else { 
            print("⚠️ GoalsManager not available for break logging")
            return false 
        }
        
        return await MainActor.run {
            // Find break goal
            guard let breakGoal = goalsManager.goals.first(where: { $0.title == "Take Breaks" }),
                  let tracker = goalsManager.trackers[breakGoal.id] else { return false }
            
            return logGoalEntries(tracker: tracker, amount: 1)
        }
    }
    
    private func logGoalEntries(tracker: GoalTracker, amount: Int) -> Bool {
        guard tracker.canLogEntry() else { return false }
        
        var loggedCount = 0
        for _ in 0..<amount {
            if let nextEntry = tracker.todayEntries.first(where: { !$0.completed }),
               tracker.canLogEntry() {
                tracker.logEntry(for: nextEntry)
                loggedCount += 1
                
                // Add small delay between entries to avoid rapid logging
                Thread.sleep(forTimeInterval: 0.1)
            } else {
                break
            }
        }
        
        return loggedCount > 0
    }
    
    // MARK: - Progress Checking
    
    func getGoalProgress() async -> String {
        guard let goalsManager = goalsManager else { 
            return "Goals are not available right now." 
        }
        
        return await MainActor.run {
            let goals = goalsManager.goals
            var progressText = "Here's your goal progress today:\n\n"
            
            for goal in goals {
                let progress = goalsManager.getProgress(for: goal)
                let percentage = Int((Double(progress) / Double(goal.targetCount)) * 100)
                
                progressText += "• \(goal.title): \(progress)/\(goal.targetCount) (\(percentage)%)\n"
            }
            
            let completedGoals = goals.filter { goal in
                let progress = goalsManager.getProgress(for: goal)
                return progress >= goal.targetCount
            }.count
            
            progressText += "\nYou've completed \(completedGoals) out of \(goals.count) goals today!"
            
            if completedGoals == goals.count {
                progressText += " Amazing work! 🎉"
            } else if completedGoals > goals.count / 2 {
                progressText += " You're doing great! Keep it up! 💪"
            } else {
                progressText += " You've got this! Keep going! 🌟"
            }
            
            return progressText
        }
    }
    
    func getPetStatus() async -> String {
        guard let petActivityManager = petActivityManager else {
            return "Your pet is not available right now."
        }
        
        return await MainActor.run {
            let petData = petActivityManager.petData
            let petName = petData.name.isEmpty ? "Your pet" : petData.name
            
            var statusText = "\(petName) is currently \(petData.state.rawValue).\n\n"
            statusText += "Energy: \(petData.energy)%\n"
            statusText += "Hydration: \(petData.hydration)%\n"
            statusText += "Satisfaction: \(petData.satisfaction)%\n"
            statusText += "Happiness: \(petData.happiness)%\n\n"
            
            // Add contextual message based on pet state
            switch petData.state {
            case .happy:
                statusText += "\(petName) is very happy with your progress! Keep up the excellent work!"
            case .ideal:
                statusText += "\(petName) is in perfect condition! You're taking great care of them!"
            case .hungry:
                statusText += "\(petName) is getting hungry. Try logging some meals to help them feel better."
            case .sleepy:
                statusText += "\(petName) looks tired. Consider taking some breaks to help them rest."
            case .passedout:
                statusText += "\(petName) is exhausted! Please focus on your goals to help them recover."
            default:
                statusText += "Take care of \(petName) by completing your daily goals!"
            }
            
            return statusText
        }
    }
}

// MARK: - App Intents Configuration

extension AppIntentsManager {
    static func configureAppIntents() {
        // This method can be called from the app delegate to set up App Intents
        print("🔗 App Intents configured for GUGU iOS")
    }
}