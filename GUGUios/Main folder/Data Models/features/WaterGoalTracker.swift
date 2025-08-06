//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import SwiftUI

@MainActor
class WaterGoalTracker: GoalTracker {
    private var regularReminderTimer: Timer?
    private let hydrationReminderInterval: TimeInterval = 2.5 * 3600 // 2.5 hours
    
    static func createDefault(analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) -> WaterGoalTracker {
        let waterGoal = Goal(
            title: "Water Intake",
            targetCount: 8,
            intervalInSeconds: TrackerConstants.hourInSeconds,
            colorScheme: .blue,
            isDefault: true
        )
        return WaterGoalTracker(goal: waterGoal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
    }
    
    override init(goal: Goal, analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) {
        super.init(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        setupRegularHydrationReminders()
    }
    
    override func logEntry(for entry: GoalEntry) {
        super.logEntry(for: entry)
        
        Task {
            // Schedule goal reminder if not fully completed
            let currentProgress = todayEntries.filter { $0.completed }.count
            let remaining = goal.targetCount - currentProgress
            if remaining > 0 {
                NotificationManager.shared.scheduleGoalReminder(
                    goalTitle: goal.title,
                    targetCount: goal.targetCount,
                    currentProgress: currentProgress
                )
            }
            
            // Schedule cooldown end notification
            if let nextAvailable = entry.nextAvailableTime {
                NotificationManager.shared.scheduleGoalCooldownEnd(
                    goalTitle: goal.title,
                    cooldownEndTime: nextAvailable
                )
            }
            
            // Reset regular hydration reminder after drinking water
            rescheduleRegularHydrationReminder()
        }
    }
    
    private func setupRegularHydrationReminders() {
        // Schedule the first regular hydration reminder
        scheduleRegularHydrationReminder()
    }
    
    private func scheduleRegularHydrationReminder() {
        // Cancel existing reminder
        regularReminderTimer?.invalidate()
        
        // Only schedule if goal is active and not fully completed
        let currentProgress = todayEntries.filter { $0.completed }.count
        guard goal.isActive && currentProgress < goal.targetCount else { return }
        
        regularReminderTimer = Timer.scheduledTimer(withTimeInterval: hydrationReminderInterval, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.sendRegularHydrationReminder()
            }
        }
        
        print("💧 Scheduled regular hydration reminder in \(hydrationReminderInterval / 3600) hours")
    }
    
    private func rescheduleRegularHydrationReminder() {
        // Reschedule the next regular reminder after drinking water
        scheduleRegularHydrationReminder()
    }
    
    @MainActor
    private func sendRegularHydrationReminder() async {
        let currentProgress = todayEntries.filter { $0.completed }.count
        let remaining = goal.targetCount - currentProgress
        
        // Only send reminder if still need to drink more water
        guard remaining > 0 else { return }
        
        let timeGreeting = getTimeBasedGreeting()
        let motivationalPhrase = getHydrationMotivation(remaining: remaining)
        
        let hydrationMessages = [
            ("\(timeGreeting)! Time to hydrate! 💧", "Your body is asking for some refreshing water! \(motivationalPhrase)"),
            ("Hydration check-in! 🌊", "\(motivationalPhrase) Your wellness journey includes staying beautifully hydrated!"),
            ("Water break reminder! 💦", "Take a moment to nourish yourself with some refreshing water! \(motivationalPhrase)"),
            ("Your body is calling! 🥤", "\(motivationalPhrase) You have \(remaining) more glasses to reach your hydration goal!"),
            ("Refresh and recharge! 💧", "\(motivationalPhrase) Each sip brings you closer to optimal health!")
        ]
        
        let (title, body) = hydrationMessages.randomElement() ?? hydrationMessages[0]
        
        NotificationManager.shared.scheduleNotification(
            id: "water-regular-reminder-\(Date().timeIntervalSince1970)",
            title: title,
            body: body,
            delay: 300, // 5 minutes delay to prevent spam
            category: .goalReminder
        )
        
        // Schedule the next regular reminder
        scheduleRegularHydrationReminder()
    }
    
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return ["Good morning", "Rise and shine", "Start your day right", "Morning hydration"].randomElement() ?? "Good morning"
        case 12..<17:
            return ["Afternoon refresh", "Midday hydration", "Keep it flowing", "Afternoon boost"].randomElement() ?? "Afternoon refresh"
        case 17..<21:
            return ["Evening hydration", "Wind down with water", "Evening refresh", "Hydrate before bed"].randomElement() ?? "Evening hydration"
        default:
            return ["Stay hydrated", "Water reminder", "Hydration check", "Don't forget water"].randomElement() ?? "Stay hydrated"
        }
    }
    
    private func getHydrationMotivation(remaining: Int) -> String {
        let progressPercent = Double(goal.targetCount - remaining) / Double(goal.targetCount)
        
        switch progressPercent {
        case 0..<0.25:
            return ["Every drop counts!", "Starting strong!", "Building great habits!", "You've got this!"].randomElement() ?? "Every drop counts!"
        case 0.25..<0.5:
            return ["Great momentum!", "You're doing amazing!", "Keep the flow going!", "Halfway there!"].randomElement() ?? "Great momentum!"
        case 0.5..<0.75:
            return ["Excellent progress!", "You're crushing it!", "So close now!", "Amazing dedication!"].randomElement() ?? "Excellent progress!"
        case 0.75..<1.0:
            return ["Almost there!", "Final stretch!", "You're so close!", "Finish strong!"].randomElement() ?? "Almost there!"
        default:
            return "Stay hydrated!"
        }
    }
    
    deinit {
        regularReminderTimer?.invalidate()
    }
}


