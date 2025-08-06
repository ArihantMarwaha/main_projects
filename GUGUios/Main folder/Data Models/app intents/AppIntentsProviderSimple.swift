//
//  AppIntentsProviderSimple.swift
//  GUGUios
//
//  Simplified App Intents without complex entities
//

import Foundation
import AppIntents
import SwiftUI

// MARK: - Simple Water Logging Intent

struct SimpleLogWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Water Intake"
    static let description = IntentDescription("Quickly log water intake")
    static let openAppWhenRun = false
    
    @Parameter(title: "Glasses", description: "Number of glasses to log", default: 1)
    var glasses: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$glasses) glasses of water")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let success = await AppIntentsManager.shared.logWater(amount: glasses)
        
        if success {
            return .result(
                dialog: IntentDialog(stringLiteral: "Logged \(glasses) glasses of water. Great job staying hydrated!")
            )
        } else {
            return .result(
                dialog: IntentDialog(stringLiteral: "Sorry, couldn't log water right now. You might be in cooldown or the app is still starting up.")
            )
        }
    }
}

// MARK: - Simple Meal Logging Intent

struct SimpleLogMealIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Meal"
    static let description = IntentDescription("Log a meal or snack")
    static let openAppWhenRun = false
    
    @Parameter(title: "Meal Type", description: "Type of meal to log", default: "Breakfast")
    var mealType: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log \(\.$mealType)")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Validate the meal type
        let validMealTypes = ["Breakfast", "Morning Snack", "Lunch", "Afternoon Snack", "Dinner"]
        let finalMealType = validMealTypes.contains(mealType) ? mealType : "Breakfast"
        
        let success = await AppIntentsManager.shared.logMeal(type: finalMealType)
        
        if success {
            return .result(
                dialog: IntentDialog(stringLiteral: "Logged \(finalMealType). Keep up the great eating habits!")
            )
        } else {
            return .result(
                dialog: IntentDialog(stringLiteral: "Sorry, couldn't log \(finalMealType) right now. You might have already logged this meal or the app is still starting up.")
            )
        }
    }
}

// MARK: - Simple Break Logging Intent

struct SimpleLogBreakIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Break"
    static let description = IntentDescription("Log a break or rest period")
    static let openAppWhenRun = false
    
    @Parameter(title: "Break Duration", description: "Length of break in minutes", default: 5)
    var duration: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Log a \(\.$duration) minute break")
    }
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let success = await AppIntentsManager.shared.logBreak(duration: duration)
        
        if success {
            return .result(
                dialog: IntentDialog(stringLiteral: "Logged a \(duration) minute break. Taking breaks is important for your health!")
            )
        } else {
            return .result(
                dialog: IntentDialog(stringLiteral: "Sorry, couldn't log break right now. You might be in cooldown or the app is still starting up.")
            )
        }
    }
}

// MARK: - Simple Goal Progress Intent

struct SimpleCheckGoalProgressIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Goal Progress"
    static let description = IntentDescription("Check progress for all goals today")
    static let openAppWhenRun = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let progress = await AppIntentsManager.shared.getGoalProgress()
        
        return .result(
            dialog: IntentDialog(stringLiteral: progress)
        )
    }
}

// MARK: - Simple Pet Status Intent

struct SimpleCheckPetStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Pet Status"
    static let description = IntentDescription("Check on your virtual pet's current state")
    static let openAppWhenRun = false
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let status = await AppIntentsManager.shared.getPetStatus()
        
        return .result(
            dialog: IntentDialog(stringLiteral: status)
        )
    }
}

// MARK: - App Shortcuts Provider
// NOTE: Moved to AppIntentsConfiguration.swift to avoid duplicate conformance