//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import Combine

@MainActor
class GoalsManager: ObservableObject {
    
    private let repository = GoalRepository()
    let analyticsManager = AnalyticsManager()
    let rewardSystem = RewardSystem()
    let petActivityManager = PetActivityManager()
    
    @Published private(set) var goals: [Goal] = []
    @Published private(set) var trackers: [UUID: GoalTracker] = [:]
    
    var categories: [GoalCategory] {
        GoalCategory.allCases
    }
    
    init() {
        loadData()
        addDefaultGoalsIfNeeded()
        setupCooldownObserver()
    }
    
    private func loadData() {
        goals = repository.loadGoals()
        
        // Initialize trackers for each goal
        goals.forEach { goal in
            let tracker = createTracker(for: goal)
            tracker.todayEntries = repository.loadEntries(forGoal: goal.id)
            trackers[goal.id] = tracker
            
            // Ensure a streak exists for this goal
            rewardSystem.ensureStreak(for: goal.id)
        }
    }
    
    private func addDefaultGoalsIfNeeded() {
        let defaultGoals = [
            Goal(
                title: "Water Intake",
                targetCount: 8,
                intervalInSeconds: TrackerConstants.hourInSeconds * 2,
                colorScheme: .blue,
                isDefault: true
            ),
            Goal(
                title: "Meals & Snacks",
                targetCount: 5,
                intervalInSeconds: TrackerConstants.hourInSeconds,
                colorScheme: .orange,
                isDefault: true
            ),
            Goal(
                title: "Take Breaks",
                targetCount: 6,
                intervalInSeconds: TrackerConstants.hourInSeconds * 2,
                colorScheme: .green,
                isDefault: true
            ),
            Goal(
                title: "Daily Meditation",
                targetCount: 1,
                intervalInSeconds: TrackerConstants.hourInSeconds * 2,
                colorScheme: .purple,
                isDefault: true
            )
        ]
        
        for defaultGoal in defaultGoals {
            if !goals.contains(where: { $0.title == defaultGoal.title }) {
                addGoal(defaultGoal)
            }
        }
    }
    
    // Allows editing of default goals, but enforces minimum values for their properties
    private func enforceMinimums(for goal: Goal) -> Goal {
        guard goal.isDefault else { return goal }
        var modifiedGoal = goal
        switch goal.title {
        case "Water Intake":
            modifiedGoal.targetCount = max(goal.targetCount, 8)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds * 2)
        case "Meals & Snacks":
            modifiedGoal.targetCount = max(goal.targetCount, 5)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds)
        case "Take Breaks":
            modifiedGoal.targetCount = max(goal.targetCount, 6)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds * 2)
        case "Daily Meditation":
            modifiedGoal.targetCount = max(goal.targetCount, 1)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds * 2)
        default:
            break
        }
        return modifiedGoal
    }
    
    // Updates a goal. Editing default goals is allowed, minimums enforced via enforceMinimums(for:)
    func updateGoal(_ goal: Goal, resetProgress: Bool = false) {
        // Enforce minimums for default goals before updating
        var goal = goal
        if goal.isDefault {
            goal = enforceMinimums(for: goal)
        }
        
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            
            if let tracker = trackers[goal.id] {
                tracker.goal = goal
                
                if resetProgress {
                    // Reset progress if requested
                    tracker.generateSchedule()
                    tracker.isInCooldown = false
                    tracker.cooldownEndTime = Date()
                }
                
                // Save and notify
                tracker.saveEntries()
                objectWillChange.send()
                NotificationCenter.default.post(name: .goalProgressUpdated, object: nil)
            }
            
            saveData()
        }
    }
    
    func addGoal(_ goal: Goal) {
        withAnimation {
            goals.append(goal)
            let tracker = createTracker(for: goal)
            trackers[goal.id] = tracker
            
            // Trigger initial analytics record
            triggerInitialAnalyticsRecord(for: goal)
            
            saveData()
        }
    }
    
    private func triggerInitialAnalyticsRecord(for goal: Goal) {
        // Create an initial entry to kickstart analytics
        let initialEntry = GoalEntry(
            goalId: goal.id,
            timestamp: Date(),
            completed: false,
            scheduledTime: Date(),
            nextAvailableTime: nil
        )
        
        // Record an initial progress to create analytics
        analyticsManager.recordProgress(for: goal, entry: initialEntry)
        
        // Ensure a streak exists for this goal
        rewardSystem.ensureStreak(for: goal.id)
    }
    
    // Prevent deletion of default goals (editing is allowed, but minimums enforced)
    func deleteGoal(_ goal: Goal) {
        guard !goal.isDefault else { return }
        Task {
            // Remove from trackers first
            trackers.removeValue(forKey: goal.id)
            
            // Remove from repository
            repository.clearEntries(forGoal: goal.id)
            
            // Remove from goals array
            withAnimation(.easeInOut(duration: 0.3)) {
                goals.removeAll { $0.id == goal.id }
            }
            
            // Save changes
            saveData()
        }
    }
    
    private func saveData() {
        repository.saveGoals(goals)
        trackers.forEach { id, tracker in
            repository.saveEntries(tracker.todayEntries, forGoal: id)
        }
    }
    
    func refreshData() {
        loadData()
        objectWillChange.send() // Ensure main view updates
    }
    
    private func createTracker(for goal: Goal) -> GoalTracker {
        switch goal.title {
        case "Water Intake":
            return WaterGoalTracker(goal: goal, analyticsManager: analyticsManager)
        case "Meals & Snacks":
            return MealGoalTracker(goal: goal, analyticsManager: analyticsManager)
        case "Take Breaks":
            return BreakGoalTracker(goal: goal, analyticsManager: analyticsManager)
        default:
            return GoalTracker(goal: goal, analyticsManager: analyticsManager)
        }
    }
    
    // Add observer for app becoming active
    func startObservingAppState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshOnAppActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func refreshOnAppActive() {
        Task {
            await MainActor.run {
                refreshData()
            }
        }
    }
    
    func updateProgress(for goal: Goal, entry: GoalEntry) {
        analyticsManager.recordProgress(for: goal, entry: entry)
        
        // Update pet activity when goal is completed
        if entry.completed {
            Task { @MainActor in
                petActivityManager.updateProgress(for: goal.title)
            }
        }
        
        // Update reward system if we have analytics
        if let analytics = analyticsManager.weeklyAnalytics[goal.id] {
            rewardSystem.updateProgress(for: goal.id, analytics: analytics)
        }
        
        objectWillChange.send()
    }
    
    private func setupCooldownObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCooldownStarted),
            name: .goalCooldownStarted,
            object: nil
        )
    }
    
    @objc private func handleCooldownStarted(_ notification: Notification) {
        guard let goalId = notification.userInfo?["goalId"] as? UUID,
              let cooldownEndTime = notification.userInfo?["cooldownEndTime"] as? Date else {
            return
        }
        
        petActivityManager.startCooldownMonitoring(for: goalId, cooldownEndTime: cooldownEndTime)
    }
    
    func getProgress(for goal: Goal) -> Int {
        // Get today's progress for the goal
        if let tracker = trackers[goal.id] {
            return tracker.todayEntries.filter { $0.completed }.count
        }
        return 0
    }
}

