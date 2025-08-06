//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import Combine
import SwiftData
import os.log

@MainActor
class GoalsManager: ObservableObject {
    private let logger = Logger(subsystem: "GUGUios", category: "GoalsManager")
    
    private var swiftDataRepository: SwiftDataGoalRepository!
    private var petRepository: SwiftDataPetRepository!
    private var journalRepository: SwiftDataJournalRepository!
    
    let analyticsManager = AnalyticsManager()
    let petActivityManager = PetActivityManager()
    
    @Published private(set) var goals: [Goal] = []
    
    // Default goals that are always present
    private let defaultGoals = [
        Goal(
            title: "Water Intake",
            targetCount: 8,
            intervalInSeconds: TrackerConstants.hourInSeconds,
            colorScheme: .blue,
            isDefault: true
        ),
        Goal(
            title: "Meals & Snacks",
            targetCount: 5,
            intervalInSeconds: TrackerConstants.hourInSeconds * 3, // 3 hours
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
            intervalInSeconds: TrackerConstants.dayInSeconds,
            colorScheme: .purple,
            isDefault: true,
            requiresSpecialInterface: true
        )
    ]
    @Published private(set) var trackers: [UUID: GoalTracker] = [:]
    
    var categories: [GoalCategory] {
        GoalCategory.allCases
    }
    
    init(modelContext: ModelContext) {
        self.swiftDataRepository = SwiftDataGoalRepository(modelContext: modelContext)
        self.petRepository = SwiftDataPetRepository(modelContext: modelContext)
        self.journalRepository = SwiftDataJournalRepository(modelContext: modelContext)
        
        // Setup PetActivityManager with SwiftData repository
        petActivityManager.setupSwiftDataRepository(petRepository)
        
        loadData()
        setupCooldownObserver()
        
        // Schedule daily summary notifications
        scheduleDailySummaryNotification()
        
        // Setup App Intents integration
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            AppIntentsManager.shared.setup(goalsManager: self, petActivityManager: self.petActivityManager)
        }
        
    }
    
    private func loadData() {
        Task { @MainActor in
            do {
                // Load ALL goals from SwiftData (both default and custom)
                var allLoadedGoals: [Goal]
                
                do {
                    // Perform database operation on main actor to prevent race conditions
                    allLoadedGoals = await swiftDataRepository.toLegacyGoals()
                    
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.logger.info("🔍 Loading \(allLoadedGoals.count) total goals from SwiftData")
                        
                        let defaultCount = allLoadedGoals.filter { $0.isDefault }.count
                        let customCount = allLoadedGoals.filter { !$0.isDefault }.count
                        self.logger.info("📊 Loaded \(defaultCount) default goals and \(customCount) custom goals")
                    }
                    
                } catch {
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.logger.error("Failed to load goals from SwiftData: \(error.localizedDescription)")
                        self.logger.warning("🔄 Emergency fallback: using hardcoded default goals")
                    }
                    allLoadedGoals = await MainActor.run { [weak self] in
                        return self?.defaultGoals ?? []
                    }
                }
            
                // Ensure we have default goals (fallback if SwiftData migration failed)
                var finalGoals = allLoadedGoals
                if allLoadedGoals.filter({ $0.isDefault }).count < 4 {
                    await MainActor.run { [weak self] in
                        self?.logger.warning("⚠️ Missing default goals, adding hardcoded fallbacks")
                    }
                    let existingTitles = Set(allLoadedGoals.map { $0.title })
                    let missingDefaults = await MainActor.run { [weak self] in
                        return self?.defaultGoals.filter { !existingTitles.contains($0.title) } ?? []
                    }
                    finalGoals.append(contentsOf: missingDefaults)
                }
                
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.goals = finalGoals
                    self.logger.info("📊 Total goals available: \(self.goals.count)")
                }
            
                // Initialize trackers for each goal with error recovery
                await withTaskGroup(of: Void.self) { group in
                    for goal in finalGoals {
                        group.addTask { [weak self] in
                            guard let self = self else { return }
                            
                            do {
                                let tracker = await MainActor.run {
                                    self.createTracker(for: goal)
                                }
                                
                                await MainActor.run { [weak self] in
                                    guard let self = self else { return }
                                    
                                    // Load entries from SwiftData with error handling on main actor
                                    let sdEntries = self.swiftDataRepository.loadEntries(forGoal: goal.id)
                                    tracker.todayEntries = sdEntries.map { $0.toLegacyGoalEntry() }
                                    self.logger.debug("✅ Loaded \(tracker.todayEntries.count) entries for \(goal.title)")
                                    
                                    self.trackers[goal.id] = tracker
                                    
                                    // Schedule custom reminders if enabled for this goal
                                    if goal.hasCustomReminders && !goal.reminderTimes.isEmpty {
                                        NotificationManager.shared.scheduleCustomGoalReminders(
                                            goalId: goal.id,
                                            goalTitle: goal.title,
                                            goalDescription: goal.description,
                                            reminderTimes: goal.reminderTimes
                                        )
                                        self.logger.debug("✅ Scheduled custom reminders for existing goal: \(goal.title)")
                                    }
                                    
                                    // Ensure a streak exists for this goal
                                }
                            } catch {
                                await MainActor.run { [weak self] in
                                    self?.logger.error("Failed to create tracker for \(goal.title): \(error.localizedDescription)")
                                }
                                // Continue with other goals
                            }
                        }
                    }
                }
            
                await MainActor.run { [weak self] in
                    self?.logger.info("✅ Data loading completed successfully")
                }
                
            } catch {
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.logger.error("Critical error during data loading: \(error.localizedDescription)")
                    
                    // Emergency recovery: ensure we at least have default goals
                    if self.goals.isEmpty {
                        self.logger.warning("🚨 Emergency recovery: loading hardcoded default goals only")
                        self.goals = self.defaultGoals
                        
                        // Create basic trackers for default goals
                        self.goals.forEach { goal in
                            let tracker = self.createTracker(for: goal)
                            self.trackers[goal.id] = tracker
                        }
                    }
                }
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
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds) // 1 hour
        case "Meals & Snacks":
            modifiedGoal.targetCount = max(goal.targetCount, 5)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds * 3) // 3 hours
        case "Take Breaks":
            modifiedGoal.targetCount = max(goal.targetCount, 6)
            modifiedGoal.intervalInSeconds = max(goal.intervalInSeconds, TrackerConstants.hourInSeconds * 2) // 2 hours
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
        var updatedGoal = goal
        if goal.isDefault {
            updatedGoal = enforceMinimums(for: goal)
        }
        
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            let oldGoal = goals[index]
            goals[index] = updatedGoal
            
            logger.info("Updating goal: \(updatedGoal.title) (isDefault: \(updatedGoal.isDefault))")
            
            // Cancel existing custom reminders for this goal
            NotificationManager.shared.cancelCustomGoalReminders(goalId: goal.id)
            
            // Schedule new custom reminders if enabled
            if updatedGoal.hasCustomReminders && !updatedGoal.reminderTimes.isEmpty {
                NotificationManager.shared.scheduleCustomGoalReminders(
                    goalId: updatedGoal.id,
                    goalTitle: updatedGoal.title,
                    goalDescription: updatedGoal.description,
                    reminderTimes: updatedGoal.reminderTimes
                )
            }
            
            if let tracker = self.trackers[goal.id] {
                tracker.goal = updatedGoal
                
                if resetProgress {
                    // Reset progress if requested
                    logger.info("Resetting progress for goal: \(updatedGoal.title)")
                    tracker.generateSchedule()
                    tracker.isInCooldown = false
                    tracker.cooldownEndTime = Date()
                }
                
                // Save entries first, then goal data
                tracker.saveEntries()
                objectWillChange.send()
                NotificationCenter.default.post(name: .goalProgressUpdated, object: nil)
            }
            
            // Always save the updated goal to SwiftData (including default goals)
            saveData()
            logger.info("✅ Goal update completed for: \(updatedGoal.title)")
        }
    }
    
    func addGoal(_ goal: Goal) {
        withAnimation {
            goals.append(goal)
            let tracker = createTracker(for: goal)
            self.trackers[goal.id] = tracker
            
            // Trigger initial analytics record
            triggerInitialAnalyticsRecord(for: goal)
            
            // Schedule custom reminders if enabled
            if goal.hasCustomReminders && !goal.reminderTimes.isEmpty {
                NotificationManager.shared.scheduleCustomGoalReminders(
                    goalId: goal.id,
                    goalTitle: goal.title,
                    goalDescription: goal.description,
                    reminderTimes: goal.reminderTimes
                )
            }
            
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
    }
    
    // Prevent deletion of default goals (editing is allowed, but minimums enforced)
    func deleteGoal(_ goal: Goal) {
        guard !goal.isDefault else { return }
        Task {
            // Cancel custom reminders for this goal
            NotificationManager.shared.cancelCustomGoalReminders(goalId: goal.id)
            
            // Remove from trackers first
            await MainActor.run { [weak self] in
                self?.trackers.removeValue(forKey: goal.id)
            }
            
            // Remove from SwiftData repository on main actor to prevent race conditions
            do {
                // First get the SDGoal from the repository
                if let sdGoal = await swiftDataRepository.goal(withId: goal.id) {
                    // Delete the actual goal (this will also delete its entries via cascade)
                    try await swiftDataRepository.deleteGoal(sdGoal)
                } else {
                    logger.warning("Goal with ID \(goal.id) not found in SwiftData")
                }
                
                await MainActor.run { [weak self] in
                    self?.logger.info("Successfully deleted goal: \(goal.title)")
                }
            } catch {
                await MainActor.run { [weak self] in
                    self?.logger.error("Failed to delete goal \(goal.title): \(error.localizedDescription)")
                }
            }
            
            // Remove from goals array
            await MainActor.run { [weak self] in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.goals.removeAll { $0.id == goal.id }
                }
            }
            
            // Reload goals to ensure consistency
            await MainActor.run { [weak self] in
                self?.loadData()
            }
        }
    }
    
    private var isSavingData = false
    
    private func saveData() {
        // Prevent concurrent save operations
        guard !isSavingData else {
            logger.debug("Save data already in progress, skipping")
            return
        }
        
        isSavingData = true
        
        Task {
            defer { 
                Task { @MainActor [weak self] in
                    self?.isSavingData = false
                }
            }
            
            do {
                // Create a snapshot of goals to avoid thread-safety issues
                let goalsSnapshot = await MainActor.run { [weak self] in
                    return self?.goals ?? []
                }
                
                // Save ALL goals to SwiftData (both default and custom) on main actor
                var savedCount = 0
                var errorCount = 0
                
                for goal in goalsSnapshot {
                    do {
                        if let existingSDGoal = await swiftDataRepository.goal(withId: goal.id) {
                            // Update existing goal
                            existingSDGoal.title = goal.title
                            existingSDGoal.goalDescription = goal.description
                            existingSDGoal.targetCount = goal.targetCount
                            existingSDGoal.intervalInSeconds = goal.intervalInSeconds
                            existingSDGoal.colorSchemeRawValue = goal.colorScheme.rawValue
                            existingSDGoal.startTime = goal.startTime
                                existingSDGoal.isActive = goal.isActive
                                existingSDGoal.isDefault = goal.isDefault
                                existingSDGoal.requiresSpecialInterface = goal.requiresSpecialInterface
                                existingSDGoal.hasCustomReminders = goal.hasCustomReminders
                                existingSDGoal.reminderTimes = goal.reminderTimes
                                try await self.swiftDataRepository.updateGoal(existingSDGoal)
                                savedCount += 1
                            } else {
                                // Create new goal
                                let newSDGoal = SDGoal.fromLegacyGoal(goal)
                                try await self.swiftDataRepository.saveGoal(newSDGoal)
                                savedCount += 1
                            }
                        } catch {
                            errorCount += 1
                            // Log error - will be handled by outer catch
                            print("❌ Failed to save goal \(goal.title): \(error.localizedDescription)")
                        }
                    }
                    
                    logger.info("✅ Saved \(savedCount) goals to SwiftData, \(errorCount) errors")
                
            } catch {
                await MainActor.run { [weak self] in
                    self?.logger.error("Failed to save data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func refreshData() {
        loadData()
        objectWillChange.send() // Ensure main view updates
    }
    
    private func createTracker(for goal: Goal) -> GoalTracker {
        let tracker: GoalTracker
        switch goal.title {
        case "Water Intake":
            tracker = WaterGoalTracker(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        case "Meals & Snacks":
            tracker = MealGoalTracker(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        case "Take Breaks":
            tracker = BreakGoalTracker(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        case "Daily Meditation":
            tracker = MeditationGoalTracker(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        default:
            tracker = GoalTracker(goal: goal, analyticsManager: analyticsManager, swiftDataRepository: swiftDataRepository)
        }
        
        // Setup SwiftData repository
        tracker.setupSwiftDataRepository(swiftDataRepository)
        
        return tracker
    }
    
    // Add observer for app becoming active with proper cleanup
    func startObservingAppState() {
        // Remove any existing observers first to prevent duplicates
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshOnAppActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        // Clean up notification observers to prevent retain cycles
        NotificationCenter.default.removeObserver(self)
        logger.info("🧹 GoalsManager deallocated and observers cleaned up")
    }
    
    private var lastRefreshTime = Date()
    private let refreshThreshold: TimeInterval = 30 // Only refresh if more than 30 seconds since last refresh
    
    @objc private func refreshOnAppActive() {
        let now = Date()
        let timeSinceLastRefresh = now.timeIntervalSince(lastRefreshTime)
        
        // Only refresh if enough time has passed and there are no active operations
        guard timeSinceLastRefresh > refreshThreshold else {
            logger.debug("Skipping refresh - only \(timeSinceLastRefresh) seconds since last refresh")
            return
        }
        
        // Check if any trackers are currently in the middle of logging
        let hasActiveOperations = trackers.values.contains { tracker in
            // Check if any tracker has a save operation in progress or is in the middle of logging
            tracker.isInCooldown && tracker.cooldownEndTime.timeIntervalSinceNow > -5
        }
        
        guard !hasActiveOperations else {
            logger.debug("Skipping refresh - active operations in progress")
            return
        }
        
        logger.info("Refreshing data on app active - \(timeSinceLastRefresh) seconds since last refresh")
        lastRefreshTime = now
        refreshData()
    }
    
    func updateProgress(for goal: Goal, entry: GoalEntry) {
        analyticsManager.recordProgress(for: goal, entry: entry)
        
        // Update pet activity when goal is completed
        if entry.completed {
            petActivityManager.updateProgress(for: goal.title)
        }
        
        // Update reward system if we have analytics
        if let analytics = analyticsManager.weeklyAnalytics[goal.id] {
        }
        
        objectWillChange.send()
    }
    
    private func setupCooldownObserver() {
        // Remove any existing observers first to prevent duplicates
        NotificationCenter.default.removeObserver(
            self,
            name: .goalCooldownStarted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCooldownStarted),
            name: .goalCooldownStarted,
            object: nil
        )
    }
    
    @objc private func handleCooldownStarted(_ notification: Notification) {
        guard let goalIdString = notification.userInfo?["goalId"] as? String,
              let goalId = UUID(uuidString: goalIdString),
              let cooldownEndTimeInterval = notification.userInfo?["cooldownEndTime"] as? TimeInterval else {
            print("⚠️ Invalid cooldown notification payload in GoalsManager")
            return
        }
        
        let cooldownEndTime = Date(timeIntervalSince1970: cooldownEndTimeInterval)
        petActivityManager.startCooldownMonitoring(for: goalId, cooldownEndTime: cooldownEndTime)
    }
    
    func getProgress(for goal: Goal) -> Int {
        // Get today's progress for the goal
        if let tracker = self.trackers[goal.id] {
            return tracker.todayEntries.filter { $0.completed }.count
        }
        return 0
    }
    
    // Daily summary notification scheduling
    private func scheduleDailySummaryNotification() {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            let completedGoals = self.goals.filter { goal in
                if let tracker = self.trackers[goal.id] {
                    return tracker.todayEntries.filter { $0.completed }.count >= goal.targetCount
                }
                return false
            }.count
            
            let totalGoals = self.goals.count
            let petHappiness = self.petActivityManager.petData.happiness
            
            NotificationManager.shared.scheduleDailySummary(
                completedGoals: completedGoals,
                totalGoals: totalGoals,
                petHappiness: petHappiness
            )
        }
    }
    
    // Method to schedule streak notifications when goals are completed
    func scheduleStreakNotification(for goal: Goal) {
        // Check if this goal has an active streak
        let streakDays = calculateStreakDays(for: goal)
        if streakDays > 1 {
            NotificationManager.shared.scheduleStreakNotification(
                goalTitle: goal.title,
                streakDays: streakDays
            )
        }
    }
    
    // Helper method to calculate streak days for a goal
    private func calculateStreakDays(for goal: Goal) -> Int {
        // Simple implementation - could be enhanced with proper streak tracking
        if let tracker = trackers[goal.id] {
            let completedToday = tracker.todayEntries.filter { $0.completed }.count
            return completedToday >= goal.targetCount ? 1 : 0
        }
        return 0
    }
}

