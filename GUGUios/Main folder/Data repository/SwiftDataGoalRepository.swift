//
//  SwiftDataGoalRepository.swift
//  GUGUios
//
//  SwiftData repository for Goal management
//

import Foundation
import SwiftData
import SwiftUI
import Combine
import os.log
@MainActor
class SwiftDataGoalRepository: ObservableObject {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "GUGUios", category: "SwiftDataGoalRepository")
    
    @Published private(set) var goals: [SDGoal] = []
    @Published private(set) var isLoading = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        ensureDefaultGoalsExist() // Ensure default goals are created first
        loadGoals() // Load synchronously during initialization
    }
    
    // MARK: - Default Goals Migration
    
    private func ensureDefaultGoalsExist() {
        logger.info("Checking if default goals exist in SwiftData...")
        
        do {
            // Check if default goals already exist - use specific batch size for safety
            let descriptor = FetchDescriptor<SDGoal>(
                predicate: #Predicate<SDGoal> { goal in
                    goal.isDefault == true
                },
                sortBy: [SortDescriptor(\.createdAt)]
            )
            
            let existingDefaultGoals = try modelContext.fetch(descriptor)
            
            if !existingDefaultGoals.isEmpty {
                logger.info("Found \(existingDefaultGoals.count) existing default goals")
                return
            }
            
            logger.info("No default goals found, creating them...")
            
            // Create default goals
            let defaultGoals = [
                SDGoal(
                    title: "Water Intake",
                    description: "Stay hydrated throughout the day",
                    targetCount: 8,
                    intervalInSeconds: TrackerConstants.hourInSeconds,
                    colorScheme: .blue,
                    startTime: Calendar.current.startOfDay(for: Date()),
                    isActive: true,
                    isDefault: true
                ),
                SDGoal(
                    title: "Meals & Snacks",
                    description: "Maintain regular eating habits",
                    targetCount: 5,
                    intervalInSeconds: TrackerConstants.hourInSeconds * 3, // 3 hours
                    colorScheme: .orange,
                    startTime: Calendar.current.startOfDay(for: Date()),
                    isActive: true,
                    isDefault: true
                ),
                SDGoal(
                    title: "Take Breaks",
                    description: "Take regular breaks from work",
                    targetCount: 6,
                    intervalInSeconds: TrackerConstants.hourInSeconds * 2, // 2 hours
                    colorScheme: .green,
                    startTime: Calendar.current.startOfDay(for: Date()),
                    isActive: true,
                    isDefault: true
                ),
                SDGoal(
                    title: "Daily Meditation",
                    description: "Practice mindfulness daily",
                    targetCount: 1,
                    intervalInSeconds: TrackerConstants.dayInSeconds,
                    colorScheme: .purple,
                    startTime: Calendar.current.startOfDay(for: Date()),
                    isActive: true,
                    isDefault: true
                )
            ]
            
            // Save default goals to SwiftData
            for goal in defaultGoals {
                modelContext.insert(goal)
                logger.info("Created default goal: \(goal.title)")
            }
            
            try modelContext.save()
            logger.info("✅ Successfully created and saved \(defaultGoals.count) default goals")
            
        } catch {
            logger.error("❌ Failed to ensure default goals exist: \(error.localizedDescription)")
            // This is critical - if we can't create default goals, the app won't work properly
            fatalError("Failed to initialize default goals: \(error)")
        }
    }
    
    // MARK: - Goal Management
    
    func loadGoals() {
        isLoading = true
        
        do {
            let descriptor = FetchDescriptor<SDGoal>()
            let fetchedGoals = try modelContext.fetch(descriptor)
            
            logger.info("SwiftDataGoalRepository: Loaded \(fetchedGoals.count) goals from database")
            fetchedGoals.forEach { goal in
                logger.debug("   - \(goal.title) (isDefault: \(goal.isDefault))")
            }
            
            // Sort goals: default goals first, then by title
            let sortedGoals = fetchedGoals.sorted { first, second in
                if first.isDefault != second.isDefault {
                    return first.isDefault && !second.isDefault
                }
                return first.title < second.title
            }
            
            self.goals = sortedGoals
            self.isLoading = false
            
        } catch {
            logger.error("Failed to load goals: \(error.localizedDescription)")
            self.goals = []
            self.isLoading = false
        }
    }
    
    func saveGoal(_ goal: SDGoal) throws {
        logger.info("Saving goal '\(goal.title)' (isDefault: \(goal.isDefault))")
        goal.updatedAt = Date()
        modelContext.insert(goal)
        try modelContext.save()
        logger.info("Goal saved successfully")
        loadGoals()
    }
    
    func updateGoal(_ goal: SDGoal) throws {
        logger.info("Updating goal: \(goal.title) (isDefault: \(goal.isDefault))")
        goal.updatedAt = Date()
        
        do {
            try modelContext.save()
            logger.debug("✅ Successfully updated goal: \(goal.title)")
        } catch {
            logger.error("❌ Failed to update goal \(goal.title): \(error.localizedDescription)")
            throw error
        }
        
        // Reload goals to ensure UI reflects changes
        loadGoals()
    }
    
    func deleteGoal(_ goal: SDGoal) throws {
        guard !goal.isDefault else {
            throw RepositoryError.cannotDeleteDefaultGoal
        }
        
        // Delete related goal streaks first
        let goalId = goal.id
        let streakDescriptor = FetchDescriptor<SDGoalStreak>(
            predicate: #Predicate<SDGoalStreak> { streak in
                streak.goalId == goalId
            }
        )
        
        do {
            let relatedStreaks = try modelContext.fetch(streakDescriptor)
            for streak in relatedStreaks {
                modelContext.delete(streak)
            }
        } catch {
            logger.error("Failed to delete related streaks for goal \(goal.id): \(error)")
        }
        
        // Delete the goal (this will cascade delete entries and analytics)
        modelContext.delete(goal)
        try modelContext.save()
        loadGoals()
    }
    
    func goal(withId id: UUID) -> SDGoal? {
        goals.first { $0.id == id }
    }
    
    // MARK: - Goal Entry Management
    
    func loadEntries(forGoal goalId: UUID) -> [SDGoalEntry] {
        logger.debug("Loading entries for goal: \(goalId)")
        
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
            
            logger.debug("Date range: \(today) to \(tomorrow)")
            
            var descriptor = FetchDescriptor<SDGoalEntry>(
                predicate: #Predicate<SDGoalEntry> { entry in
                    entry.goalId == goalId &&
                    entry.scheduledTime >= today &&
                    entry.scheduledTime < tomorrow
                },
                sortBy: [SortDescriptor(\SDGoalEntry.scheduledTime, order: .forward)]
            )
            descriptor.fetchLimit = 50 // Limit batch size to prevent memory issues
            
            let entries = try modelContext.fetch(descriptor)
            logger.info("Loaded \(entries.count) entries for goal \(goalId)")
            
            if entries.isEmpty {
                logger.debug("No entries found for today for goal \(goalId)")
            } else {
                entries.forEach { entry in
                    logger.debug("  Entry: \(entry.id) - completed: \(entry.completed) - scheduled: \(entry.scheduledTime)")
                }
            }
            
            return entries
            
        } catch {
            logger.error("Failed to load entries for goal \(goalId): \(error.localizedDescription)")
            
            // Log additional context for debugging
            if let swiftDataError = error as? any Error {
                logger.error("SwiftData error context: \(String(describing: swiftDataError))")
            }
            
            return []
        }
    }
    
    func saveEntry(_ entry: SDGoalEntry) throws {
        logger.debug("Attempting to save entry: \(entry.id) for goal: \(entry.goalId)")
        
        // Validate entry data before processing
        guard !entry.id.uuidString.isEmpty,
              !entry.goalId.uuidString.isEmpty else {
            logger.error("Invalid entry data: empty IDs")
            throw RepositoryError.invalidData
        }
        
        do {
            // Check if entry already exists
            let entryId = entry.id
            let descriptor = FetchDescriptor<SDGoalEntry>(
                predicate: #Predicate<SDGoalEntry> { $0.id == entryId }
            )
            
            let existingEntries = try modelContext.fetch(descriptor)
            
            if let existingEntry = existingEntries.first {
                // Update existing entry with validation
                existingEntry.goalId = entry.goalId
                existingEntry.timestamp = entry.timestamp
                existingEntry.completed = entry.completed
                existingEntry.scheduledTime = entry.scheduledTime
                existingEntry.nextAvailableTime = entry.nextAvailableTime
                existingEntry.mealType = entry.mealType
                logger.info("Updated existing entry with ID: \(entry.id)")
            } else {
                // Insert new entry
                modelContext.insert(entry)
                logger.info("Inserted new entry with ID: \(entry.id)")
            }
            
            // Save with additional error context
            try modelContext.save()
            logger.debug("Successfully saved entry: \(entry.id)")
            
        } catch {
            logger.error("Failed to save entry \(entry.id): \(error.localizedDescription)")
            
            // Add more specific error context
            if let swiftDataError = error as? any Error {
                logger.error("SwiftData error details: \(String(describing: swiftDataError))")
            }
            
            // Re-throw with context
            throw error
        }
    }
    
    func updateEntry(_ entry: SDGoalEntry) throws {
        try modelContext.save()
    }
    
    func deleteEntry(_ entry: SDGoalEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    func clearEntries(forGoal goalId: UUID) throws {
        let descriptor = FetchDescriptor<SDGoalEntry>(
            predicate: #Predicate<SDGoalEntry> { $0.goalId == goalId }
        )
        
        let entries = try modelContext.fetch(descriptor)
        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
    
    // MARK: - Analytics and Progress
    
    func getWeeklyProgress(for goalId: UUID) -> SDAnalytics? {
        do {
            let weekStart = Calendar.current.startOfWeek()
            let descriptor = FetchDescriptor<SDAnalytics>(
                predicate: #Predicate<SDAnalytics> { analytics in
                    analytics.goalId == goalId &&
                    analytics.weekStartDate == weekStart
                }
            )
            
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to load analytics for goal \(goalId): \(error)")
            return nil
        }
    }
    
    func getTodayProgress(for goalId: UUID) -> Int {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
            
            // Optimize query by limiting fetch to only count
            var descriptor = FetchDescriptor<SDGoalEntry>(
                predicate: #Predicate<SDGoalEntry> { entry in
                    entry.goalId == goalId &&
                    entry.completed == true &&
                    entry.timestamp >= today &&
                    entry.timestamp < tomorrow
                }
            )
            
            // Only fetch what we need to reduce memory usage
            descriptor.fetchLimit = 50 // Reasonable upper bound for daily goals
            
            let completedEntries = try modelContext.fetch(descriptor)
            let count = completedEntries.count
            
            logger.debug("Today's progress for goal \(goalId): \(count) completed entries")
            return count
            
        } catch {
            logger.error("Failed to get today's progress for goal \(goalId): \(error.localizedDescription)")
            return 0
        }
    }
    
    // MARK: - Compatibility Methods (for gradual migration)
    
    func toLegacyGoals() -> [Goal] {
        return goals.map { $0.toLegacyGoal() }
    }
    
    func toLegacyEntries(for goalId: UUID) -> [GoalEntry] {
        let sdEntries = loadEntries(forGoal: goalId)
        return sdEntries.map { $0.toLegacyGoalEntry() }
    }
    
    // MARK: - Batch Operations
    
    func saveBatch<T: PersistentModel>(_ items: [T]) throws {
        guard !items.isEmpty else { return }
        
        // Insert all items first
        for item in items {
            modelContext.insert(item)
        }
        
        // Single save operation for better performance
        try modelContext.save()
        logger.info("📦 Batch saved \(items.count) items")
    }
    
    // Enhanced batch operations for goal entries
    func saveBatchEntries(_ entries: [SDGoalEntry]) throws {
        guard !entries.isEmpty else { return }
        
        let startTime = Date()
        logger.info("📦 Starting batch save of \(entries.count) entries")
        
        // Check for existing entries to avoid duplicates
        let entryIds = entries.map { $0.id }
        let descriptor = FetchDescriptor<SDGoalEntry>(
            predicate: #Predicate<SDGoalEntry> { entry in
                entryIds.contains(entry.id)
            }
        )
        
        let existingEntries = try modelContext.fetch(descriptor)
        let existingIds = Set(existingEntries.map { $0.id })
        
        // Only insert new entries
        let newEntries = entries.filter { !existingIds.contains($0.id) }
        let updatedEntries = entries.filter { existingIds.contains($0.id) }
        
        // Insert new entries
        for entry in newEntries {
            modelContext.insert(entry)
        }
        
        // Update existing entries
        for entry in updatedEntries {
            if let existing = existingEntries.first(where: { $0.id == entry.id }) {
                existing.goalId = entry.goalId
                existing.timestamp = entry.timestamp
                existing.completed = entry.completed
                existing.scheduledTime = entry.scheduledTime
                existing.nextAvailableTime = entry.nextAvailableTime
                existing.mealType = entry.mealType
            }
        }
        
        // Single save operation
        try modelContext.save()
        
        let duration = Date().timeIntervalSince(startTime)
        logger.info("✅ Batch operation completed in \(String(format: "%.2f", duration))s: \(newEntries.count) new, \(updatedEntries.count) updated")
    }
    
    func performBatchUpdate<T: PersistentModel>(
        _ type: T.Type,
        predicate: Predicate<T>? = nil,
        update: @escaping (T) -> Void
    ) throws {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        let items = try modelContext.fetch(descriptor)
        
        for item in items {
            update(item)
        }
        
        try modelContext.save()
    }
}

// MARK: - Repository Errors

enum RepositoryError: LocalizedError {
    case cannotDeleteDefaultGoal
    case goalNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .cannotDeleteDefaultGoal:
            return "Cannot delete default goals"
        case .goalNotFound:
            return "Goal not found"
        case .invalidData:
            return "Invalid data provided"
        }
    }
}
