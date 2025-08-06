//
//  AppIntentsConfiguration.swift
//  GUGUios
//
//  Central configuration for all App Intents and Siri Shortcuts
//

import Foundation
import AppIntents

// MARK: - Comprehensive App Shortcuts Provider (Using Simple Intents)

struct GUGUiosAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // MARK: - Quick Actions
            AppShortcut(
                intent: SimpleLogWaterIntent(),
                phrases: [
                    "Quick water in \(.applicationName)",
                    "I drank water in \(.applicationName)",
                    "Log water quickly in \(.applicationName)",
                    "Water logged in \(.applicationName)",
                    "Hydrate in \(.applicationName)"
                ],
                shortTitle: "Quick Water",
                systemImageName: "drop.fill"
            ),
            
            AppShortcut(
                intent: SimpleLogBreakIntent(),
                phrases: [
                    "Quick break in \(.applicationName)",
                    "I took a break in \(.applicationName)",
                    "Log break quickly in \(.applicationName)",
                    "Break time in \(.applicationName)",
                    "Rest logged in \(.applicationName)"
                ],
                shortTitle: "Quick Break",
                systemImageName: "pause.circle.fill"
            ),
            
            // MARK: - Progress Checking
            AppShortcut(
                intent: SimpleCheckGoalProgressIntent(),
                phrases: [
                    "Check my progress in \(.applicationName)",
                    "How am I doing in \(.applicationName)",
                    "Show my goal progress in \(.applicationName)",
                    "Check goals in \(.applicationName)",
                    "My progress today in \(.applicationName)"
                ],
                shortTitle: "Check Progress",
                systemImageName: "chart.bar.fill"
            ),
            
            // MARK: - Pet Interaction
            AppShortcut(
                intent: SimpleCheckPetStatusIntent(),
                phrases: [
                    "Check my pet in \(.applicationName)",
                    "How is my pet in \(.applicationName)",
                    "Pet status in \(.applicationName)",
                    "Check on my pet in \(.applicationName)",
                    "How is my companion in \(.applicationName)"
                ],
                shortTitle: "Check Pet",
                systemImageName: "pawprint.fill"
            ),
            
            // MARK: - Specific Meal Logging
            AppShortcut(
                intent: SimpleLogMealIntent(),
                phrases: [
                    "Log meal in \(.applicationName)",
                    "I ate in \(.applicationName)",
                    "Record meal in \(.applicationName)",
                    "Log food in \(.applicationName)",
                    "Meal logged in \(.applicationName)"
                ],
                shortTitle: "Log Meal",
                systemImageName: "fork.knife"
            )
        ]
    }
}

// MARK: - App Intent Donation Helper

class AppIntentsDonationHelper {
    static let shared = AppIntentsDonationHelper()
    
    private init() {}
    
    /// Donate frequently used intents to help Siri learn user patterns
    func donateCommonIntents() {
        Task {
            // Donate water logging (most common action)
            let waterIntent = SimpleLogWaterIntent()
            try? await waterIntent.donate()
            
            // Donate break logging
            let breakIntent = SimpleLogBreakIntent()
            try? await breakIntent.donate()
            
            // Donate progress checking
            let progressIntent = SimpleCheckGoalProgressIntent()
            try? await progressIntent.donate()
            
            print("🎯 Donated common App Intents to Siri")
        }
    }
    
    /// Donate context-specific intents based on time of day
    func donateContextualIntents() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        Task {
            switch hour {
            case 6...10: // Morning
                let waterIntent = SimpleLogWaterIntent()
                try? await waterIntent.donate()
                
            case 11...13: // Lunch time
                let lunchIntent = SimpleLogMealIntent()
                lunchIntent.mealType = "Lunch"
                try? await lunchIntent.donate()
                
            case 17...21: // Evening
                let progressIntent = SimpleCheckGoalProgressIntent()
                try? await progressIntent.donate()
                
            default:
                // General donation for other times
                donateCommonIntents()
            }
            
            print("🕐 Donated contextual App Intents for hour: \(hour)")
        }
    }
}

// MARK: - App Intent Analytics

class AppIntentsAnalytics {
    static let shared = AppIntentsAnalytics()
    
    private init() {}
    
    func trackIntentUsage(_ intentName: String) {
        print("📊 App Intent used: \(intentName)")
        // Here you could integrate with your analytics system
        // AnalyticsManager.shared.track(event: "app_intent_used", properties: ["intent": intentName])
    }
}

// MARK: - Integration Extensions

extension AppIntentsManager {
    func donateIntentsBasedOnActivity() {
        AppIntentsDonationHelper.shared.donateContextualIntents()
    }
}