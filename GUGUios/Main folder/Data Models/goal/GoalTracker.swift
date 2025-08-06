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
    private weak var swiftDataRepository: SwiftDataGoalRepository?
    let analyticsManager: AnalyticsManager
    
    init(goal: Goal, analyticsManager: AnalyticsManager, swiftDataRepository: SwiftDataGoalRepository? = nil) {
        self.goal = goal
        self.analyticsManager = analyticsManager
        self.swiftDataRepository = swiftDataRepository
        loadSavedData()
    }
    
    deinit {
        // Can't access MainActor-isolated properties in deinit
        print("🧹 GoalTracker deallocated")
    }
    
    func setupSwiftDataRepository(_ repository: SwiftDataGoalRepository) {
        self.swiftDataRepository = repository
        loadSavedData() // Reload data from SwiftData
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
            NotificationCenter.default.post(
                name: .goalProgressUpdated, 
                object: nil,
                userInfo: ["goalTitle": goal.title, "goalType": goal.title]
            )
        }
    }
    
    func loadSavedData() {
        do {
            if let swiftDataRepo = swiftDataRepository {
                // Load from SwiftData with error recovery
                let sdEntries = swiftDataRepo.loadEntries(forGoal: goal.id)
                todayEntries = sdEntries.map { $0.toLegacyGoalEntry() }
                print("✅ Loaded \(todayEntries.count) entries for goal: \(goal.title)")
            } else {
                // No repository available, start with empty entries
                todayEntries = []
                print("⚠️ No SwiftData repository available, starting with empty entries")
            }
            
            // Validate loaded entries
            let validEntries = todayEntries.filter { entry in
                // Ensure basic data integrity
                !entry.id.uuidString.isEmpty && entry.goalId == goal.id
            }
            
            if validEntries.count != todayEntries.count {
                print("⚠️ Found \(todayEntries.count - validEntries.count) invalid entries, filtering out")
                todayEntries = validEntries
            }
            
            // If no valid entries exist for today, generate new schedule
            if todayEntries.isEmpty {
                print("📅 No valid entries found, generating new schedule")
                generateSchedule()
                
                // Try to save, but don't crash if it fails
                do {
                    saveEntries()
                } catch {
                    print("⚠️ Failed to save initial schedule: \(error.localizedDescription)")
                    // Continue anyway - user can still use the app
                }
            }
            
            updateCooldownState()
            
        } catch {
            print("❌ Error loading saved data for goal \(goal.title): \(error.localizedDescription)")
            
            // Recovery: start with fresh schedule
            print("🔄 Recovering by generating fresh schedule")
            todayEntries = []
            generateSchedule()
            
            // Don't try to save if we're in error recovery mode
            print("⚠️ Running in recovery mode - schedule not persisted")
        }
    }
    
    private func updateCooldownState() {
        // Find the most recent completed entry
        let completedEntries = todayEntries.filter { $0.completed }
        
        if let lastCompleted = completedEntries.max(by: { $0.timestamp < $1.timestamp }),
           let nextAvailable = lastCompleted.nextAvailableTime {
            let now = Date()
            isInCooldown = now < nextAvailable
            cooldownEndTime = nextAvailable
            
            if isInCooldown {
                print("🔄 Restored cooldown state: active until \(nextAvailable)")
            } else {
                print("✅ Cooldown expired, ready for next entry")
            }
        } else {
            // No completed entries or no cooldown needed
            isInCooldown = false
            cooldownEndTime = Date()
            print("📝 No cooldown active")
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
        // Goal must be active first
        guard goal.isActive else { return false }
        
        // Check if goal is already at 100% completion
        let completedCount = todayEntries.filter { $0.completed }.count
        if completedCount >= goal.targetCount {
            print("🎯 Goal \(goal.title) already at 100% completion")
            return false
        }
        
        // No cooldown if interval is 0
        if goal.intervalInSeconds == 0 {
            return true
        }
        
        // Check if we're past the cooldown time
        let now = Date()
        let canLog = now >= cooldownEndTime
        
        // If we can log but still marked as in cooldown, update the state
        if canLog && isInCooldown {
            isInCooldown = false
        }
        
        return canLog
    }
    
    func logEntry(for entry: GoalEntry) {
        print("🎯 Logging entry for goal: \(goal.title), entry ID: \(entry.id)")
        
        // Enhanced throttling to prevent UI hangs from rapid taps
        let now = Date()
        guard !isLogging && now.timeIntervalSince(lastLogTime) >= minLogInterval else {
            print("⚠️ Ignoring rapid log attempt - \(now.timeIntervalSince(lastLogTime)) seconds since last log")
            return
        }
        
        // Additional check to prevent concurrent operations
        guard !isSaving else {
            print("⚠️ Save operation in progress, deferring log")
            // Defer the operation to avoid conflicts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.logEntry(for: entry)
            }
            return
        }
        
        guard canLogEntry() else { 
            print("⚠️ Cannot log entry - cooldown active or goal inactive")
            return 
        }
        
        guard let index = todayEntries.firstIndex(where: { $0.id == entry.id }) else {
            print("❌ Entry not found in todayEntries for ID: \(entry.id)")
            return
        }
        
        // Check if goal is already at 100% completion
        let completedCount = todayEntries.filter { $0.completed }.count
        if completedCount >= goal.targetCount {
            print("🎯 Goal \(goal.title) is already at 100% completion (\(completedCount)/\(goal.targetCount))")
            
            // Post notification that goal is complete
            NotificationCenter.default.post(
                name: .goalFullyCompleted,
                object: nil,
                userInfo: [
                    "goalId": goal.id.uuidString,
                    "goalTitle": goal.title,
                    "completedCount": completedCount,
                    "targetCount": goal.targetCount
                ]
            )
            return
        }
        
        // Ensure the entry we're trying to log isn't already completed
        if todayEntries[index].completed {
            print("⚠️ Entry already completed, cannot log again")
            return
        }
        
        // Set logging state with proper cleanup
        isLogging = true
        lastLogTime = now
        
        // Ensure logging state is reset even if operation fails
        defer { 
            Task { @MainActor [weak self] in
                self?.isLogging = false
            }
        }
        
        print("✅ Found entry at index \(index), proceeding with logging")
        
        // Calculate next available time
        let nextAvailableTime: Date
        if goal.intervalInSeconds == 0 {
            nextAvailableTime = Date()
        } else {
            nextAvailableTime = Date().addingTimeInterval(goal.intervalInSeconds)
        }
        
        // Create new entry
        let newEntry = GoalEntry(
            goalId: goal.id,
            timestamp: Date(),
            completed: true,
            scheduledTime: entry.scheduledTime,
            nextAvailableTime: goal.intervalInSeconds == 0 ? nil : nextAvailableTime,
            mealType: entry.mealType
        )
        
        print("📝 Created new entry, updating UI...")
        
        // Update UI state immediately
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
            todayEntries[index] = newEntry
            isInCooldown = goal.intervalInSeconds > 0
            cooldownEndTime = nextAvailableTime
            objectWillChange.send()
        }
        
        // Handle analytics and data operations asynchronously to prevent UI blocking
        Task {
            print("📊 Recording analytics...")
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                self.analyticsManager.recordProgress(for: self.goal, entry: newEntry)
            }
            
            print("💾 Saving entries...")
            saveEntries()
            
            await MainActor.run {
                print("📢 Posting notifications...")
            }
        }
        // Post notifications
        NotificationCenter.default.post(
            name: .goalProgressUpdated,
            object: nil,
            userInfo: [
                "goalId": goal.id.uuidString,
                "entryId": newEntry.id.uuidString,
                "goalTitle": goal.title,
                "goalType": goal.title,
                "completed": newEntry.completed
            ]
        )
        
        // Handle cooldown notification
        if goal.intervalInSeconds > 0 {
            NotificationCenter.default.post(
                name: .goalCooldownStarted,
                object: nil,
                userInfo: [
                    "goalId": goal.id.uuidString,
                    "cooldownEndTime": nextAvailableTime.timeIntervalSince1970,
                    "goalType": goal.title
                ]
            )
        }
        
        // Check if goal is now fully completed and trigger streak notification
        let newCompletedCount = todayEntries.filter { $0.completed }.count
        if newCompletedCount >= goal.targetCount {
            NotificationCenter.default.post(
                name: .goalFullyCompleted,
                object: nil,
                userInfo: [
                    "goalId": goal.id.uuidString,
                    "goalTitle": goal.title,
                    "completedCount": newCompletedCount,
                    "targetCount": goal.targetCount
                ]
            )
            
            // Schedule streak notification (simple implementation)
            Task {
                NotificationManager.shared.scheduleStreakNotification(
                    goalTitle: goal.title,
                    streakDays: 1 // Enhanced streak tracking could be added later
                )
            }
        }
        
        print("✅ Goal entry logged successfully!")
    }
    
    private var isSaving = false
    private var isLogging = false
    private var lastLogTime = Date.distantPast
    private let minLogInterval: TimeInterval = 1.0 // Minimum 1 second between logs
    
    func saveEntries() {
        guard let swiftDataRepo = swiftDataRepository else {
            print("⚠️ No SwiftData repository available for saving entries")
            return
        }
        
        // Prevent concurrent save operations
        guard !isSaving else {
            print("⚠️ Save already in progress, skipping")
            return
        }
        
        isSaving = true
        
        Task {
            defer {
                Task { @MainActor [weak self] in
                    self?.isSaving = false
                }
            }
            
            // Create snapshot of entries to avoid thread-safety issues
            let entriesSnapshot = await MainActor.run { [weak self] in
                return self?.todayEntries ?? []
            }
            
            await MainActor.run {
                print("💾 Starting to save \(entriesSnapshot.count) entries...")
            }
            
            // Perform database operations on main actor to prevent race conditions
            guard let swiftDataRepo = swiftDataRepository else { return }
            
            var savedCount = 0
            var errorCount = 0
            
            // Batch save entries to improve performance
            for entry in entriesSnapshot {
                do {
                    let sdEntry = SDGoalEntry.fromLegacyGoalEntry(entry)
                    try swiftDataRepo.saveEntry(sdEntry)
                    savedCount += 1
                    print("✅ Saved entry \(entry.id)")
                } catch {
                    errorCount += 1
                    print("❌ Failed to save entry \(entry.id): \(error.localizedDescription)")
                    
                    // Log detailed error information for debugging
                    if let localizedError = error as? LocalizedError {
                        print("   Error description: \(localizedError.errorDescription ?? "Unknown")")
                        print("   Failure reason: \(localizedError.failureReason ?? "Unknown")")
                    }
                }
            }
            
            await MainActor.run {
                print("💾 Save operation completed: \(savedCount) saved, \(errorCount) errors")
            }
        }
    }
    
    func getProgress() -> Double {
        let completedCount = todayEntries.filter { $0.completed }.count
        return Double(completedCount) / Double(goal.targetCount)
    }
    
    func isFullyCompleted() -> Bool {
        let completedCount = todayEntries.filter { $0.completed }.count
        return completedCount >= goal.targetCount
    }
    
    func getCompletedCount() -> Int {
        return todayEntries.filter { $0.completed }.count
    }
}


