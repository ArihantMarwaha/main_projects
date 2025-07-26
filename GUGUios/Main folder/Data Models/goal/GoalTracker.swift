//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import Combine

@MainActor
class GoalTracker: ObservableObject {
    
    @Published var goal: Goal {
        didSet {
            handleGoalUpdate(oldValue: oldValue)
        }
    }
    @Published var todayEntries: [GoalEntry] = []
    @Published var isInCooldown: Bool = false
    @Published var cooldownEndTime: Date = Date()
    private let repository = GoalRepository()
    let analyticsManager: AnalyticsManager
    
    init(goal: Goal, analyticsManager: AnalyticsManager) {
        self.goal = goal
        self.analyticsManager = analyticsManager
        loadSavedData()
    }
    
    private func handleGoalUpdate(oldValue: Goal) {
        // Check if target count or interval has changed
        if oldValue.targetCount != goal.targetCount ||
           oldValue.intervalInSeconds != goal.intervalInSeconds {
            // Reset cooldown state for no interval or reduced interval
            if goal.intervalInSeconds == 0 || goal.intervalInSeconds < oldValue.intervalInSeconds {
                isInCooldown = false
                cooldownEndTime = Date()
            }
            
            // Update schedule for new target count
            let completedEntries = todayEntries.filter { $0.completed }
            generateSchedule()
            
            // Preserve completed entries up to the new target count
            for (index, entry) in completedEntries.enumerated() {
                if index < todayEntries.count {
                    let newEntry = GoalEntry(
                        goalId: goal.id,
                        timestamp: entry.timestamp,
                        completed: true,
                        scheduledTime: todayEntries[index].scheduledTime,
                        nextAvailableTime: entry.nextAvailableTime,
                        mealType: entry.mealType
                    )
                    todayEntries[index] = newEntry
                }
            }
            
            // Save and notify
            saveEntries()
            objectWillChange.send()
            NotificationCenter.default.post(name: .goalProgressUpdated, object: nil)
        }
    }
    
    func loadSavedData() {
        todayEntries = repository.loadEntries(forGoal: goal.id)
        
        // If no entries exist for today, generate new schedule
        if todayEntries.isEmpty {
            generateSchedule()
            saveEntries()
        }
        
        updateCooldownState()
    }
    
    private func updateCooldownState() {
        if let lastCompleted = todayEntries.filter({ $0.completed }).max(by: { $0.timestamp < $1.timestamp }),
           let nextAvailable = lastCompleted.nextAvailableTime {
            isInCooldown = Date() < nextAvailable
            cooldownEndTime = nextAvailable
        }
    }
    
    func generateSchedule() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        todayEntries = []
        
        for i in 0..<goal.targetCount {
            let scheduledTime = calendar.date(
                byAdding: .second,
                value: Int(Double(i) * goal.intervalInSeconds),
                to: goal.startTime
            ) ?? Date()
            
            // Ensure scheduled time is for today
            let adjustedTime = calendar.date(
                byAdding: .day,
                value: 0,
                to: calendar.date(
                    bySettingHour: calendar.component(.hour, from: scheduledTime),
                    minute: calendar.component(.minute, from: scheduledTime),
                    second: calendar.component(.second, from: scheduledTime),
                    of: today
                ) ?? today
            ) ?? today
            
            let entry = GoalEntry(
                goalId: goal.id,
                scheduledTime: adjustedTime
            )
            todayEntries.append(entry)
        }
    }
    
    func canLogEntry() -> Bool {
        // No cooldown if interval is 0
        if goal.intervalInSeconds == 0 {
            return goal.isActive
        }
        
        // Check if we're past the cooldown time and goal is active
        let now = Date()
        let canLog = now >= cooldownEndTime && goal.isActive
        
        // If we can log but still marked as in cooldown, update the state
        if canLog && isInCooldown {
            isInCooldown = false
        }
        
        return canLog
    }
    
    func logEntry(for entry: GoalEntry) {
        guard canLogEntry() else { return }
        if let index = todayEntries.firstIndex(where: { $0.id == entry.id }) {
            let nextAvailableTime: Date
            if goal.intervalInSeconds == 0 {
                nextAvailableTime = Date()
            } else {
                nextAvailableTime = Date().addingTimeInterval(goal.intervalInSeconds)
            }
            
            let newEntry = GoalEntry(
                goalId: goal.id,
                timestamp: Date(),
                completed: true,
                scheduledTime: entry.scheduledTime,
                nextAvailableTime: goal.intervalInSeconds == 0 ? nil : nextAvailableTime,
                mealType: entry.mealType
            )
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
                todayEntries[index] = newEntry
                isInCooldown = goal.intervalInSeconds > 0
                cooldownEndTime = nextAvailableTime
                
                // Record analytics and trigger pet updates
                analyticsManager.recordProgress(for: goal, entry: newEntry)
                
                // Save entries and notify
                saveEntries()
                objectWillChange.send()
                
                // Post notifications with goal type
                NotificationCenter.default.post(
                    name: .goalProgressUpdated,
                    object: nil,
                    userInfo: [
                        "goal": goal,
                        "entry": newEntry,
                        "goalType": goal.title
                    ]
                )
                
                // Handle cooldown notification
                if goal.intervalInSeconds > 0 {
                    NotificationCenter.default.post(
                        name: .goalCooldownStarted,
                        object: nil,
                        userInfo: [
                            "goalId": goal.id,
                            "cooldownEndTime": nextAvailableTime,
                            "goalType": goal.title
                        ]
                    )
                }
            }
        }
    }
    
    func saveEntries() {
        repository.saveEntries(todayEntries, forGoal: goal.id)
    }
    
    func getProgress() -> Double {
        let completedCount = todayEntries.filter { $0.completed }.count
        return Double(completedCount) / Double(goal.targetCount)
    }
}


