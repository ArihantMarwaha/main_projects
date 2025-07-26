import Foundation
import Combine
// Represents a goal's streak information
struct GoalStreak: Codable {
    var currentStreak: Int
    var bestStreak: Int
    var lastCompletionDate: Date?
    var totalCompletions: Int
    var perfectWeeks: Int   
    
    init(currentStreak: Int = 0, 
         bestStreak: Int = 0, 
         lastCompletionDate: Date? = nil,
         totalCompletions: Int = 0,
         perfectWeeks: Int = 0) {
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.lastCompletionDate = lastCompletionDate
        self.totalCompletions = totalCompletions
        self.perfectWeeks = perfectWeeks
    }
}

@MainActor
class RewardSystem: ObservableObject {
    @Published private(set) var goalStreaks: [UUID: GoalStreak] = [:]
    @Published private(set) var achievements: [Achievement] = []
    @Published private(set) var criteria: [AchievementCriteria] = []
    @Published private(set) var totalPoints: Int = 0
    
    private let repository: RewardRepository
    
    init(repository: RewardRepository? = nil) {
        self.repository = repository ?? RewardRepository()
        loadData()
        initializeDefaultAchievements()
    }
    
    private func initializeDefaultAchievements() {
        // Only initialize if we don't have any achievements yet
        guard achievements.isEmpty else { return }
        
        let defaultAchievements = [
            Achievement(type: .waterStreak, level: .bronze),
            Achievement(type: .mealStreak, level: .bronze),
            Achievement(type: .breakStreak, level: .bronze),
            Achievement(type: .petCare, level: .bronze),
            Achievement(type: .consistency, level: .bronze)
        ]
        
        achievements = defaultAchievements
        saveData() // Save after initializing default achievements
    }
    
    func ensureStreak(for goalId: UUID) {
        // If no streak exists for this goal, create a default one
        if goalStreaks[goalId] == nil {
            goalStreaks[goalId] = GoalStreak()
            saveData() // Save after adding new streak
        }
    }
    
    func setStreak(for goalId: UUID, streak: GoalStreak) {
        // Method to set a streak for a specific goal
        goalStreaks[goalId] = streak
        saveData() // Save after updating streak
    }
    
    func getStreak(for goalId: UUID) -> GoalStreak {
        // Method to get a streak, creating a default one if it doesn't exist
        if let streak = goalStreaks[goalId] {
            return streak
        }
        
        let defaultStreak = GoalStreak()
        setStreak(for: goalId, streak: defaultStreak)
        return defaultStreak
    }
    
    func updateProgress(for type: AchievementType, progress: Double, level: AchievementLevel = .bronze) {
        if let index = achievements.firstIndex(where: { $0.type == type && $0.level == level }) {
            var achievement = achievements[index]
            achievement.updateProgress(newProgress: progress)
            achievements[index] = achievement
            
            if achievement.isCompleted {
                calculatePoints(for: type, level: level)
                tryUpgradeAchievement(type: type, currentLevel: level)
                objectWillChange.send()
                saveData() // Save after completing and upgrading achievement
            } else {
                saveData() // Save after updating progress if not completed yet
            }
        } else {
            // Create new achievement if it doesn't exist
            var newAchievement = Achievement(
                type: type,
                level: level,
                dateEarned: Date(),
                progress: 0.0
            )
            newAchievement.updateProgress(newProgress: progress)
            achievements.append(newAchievement)
            
            if newAchievement.isCompleted {
                calculatePoints(for: type, level: level)
            }
            objectWillChange.send()
            saveData() // Save after adding new achievement
        }
    }
    
    private func tryUpgradeAchievement(type: AchievementType, currentLevel: AchievementLevel) {
        let nextLevel: AchievementLevel? = {
            switch currentLevel {
            case .bronze: return .silver
            case .silver: return .gold
            case .gold: return .platinum
            case .platinum: return nil
            }
        }()
        
        if let nextLevel = nextLevel {
            // Check if we already have this level
            if !achievements.contains(where: { $0.type == type && $0.level == nextLevel }) {
                let newAchievement = Achievement(
                    type: type,
                    level: nextLevel,
                    progress: 0.0
                )
                achievements.append(newAchievement)
                saveData() // Save after adding upgraded achievement
            }
        }
    }
    
    func updateProgress(for goalId: UUID, analytics: WeeklyAnalytics) {
        // Update streaks
        var streak = getStreak(for: goalId)
        updateStreak(&streak, with: analytics)
        setStreak(for: goalId, streak: streak)
        
        // Check for achievements
        checkAchievements(for: goalId, streak: streak, analytics: analytics)
        
        // Recalculate points and save all changes after updating streaks and achievements
        calculatePoints()
        saveData()
    }
    
    private func updateStreak(_ streak: inout GoalStreak, with analytics: WeeklyAnalytics) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Update total completions
        let todayData = analytics.dailyData.first { 
            calendar.isDate($0.date, inSameDayAs: today) 
        }
        if let data = todayData, data.completedCount >= data.targetCount {
            streak.totalCompletions += 1
            
            // Update streak
            if let lastDate = streak.lastCompletionDate,
               calendar.isDateInYesterday(lastDate) {
                streak.currentStreak += 1
                streak.bestStreak = max(streak.currentStreak, streak.bestStreak)
            } else if streak.lastCompletionDate == nil || 
                     !calendar.isDate(streak.lastCompletionDate!, inSameDayAs: today) {
                streak.currentStreak = 1
            }
            
            streak.lastCompletionDate = today
        } else if let lastDate = streak.lastCompletionDate,
                  !calendar.isDateInYesterday(lastDate) && 
                  !calendar.isDate(lastDate, inSameDayAs: today) {
            // Break streak if a day was missed
            streak.currentStreak = 0
        }
        
        // Check for perfect week
        let weeklyRate = analytics.weeklyCompletionRate
        if weeklyRate >= 1.0 {
            streak.perfectWeeks += 1
        }
    }
    
    private func checkAchievements(for goalId: UUID, streak: GoalStreak, analytics: WeeklyAnalytics) {
        // Check streak-based achievements
        for criterion in criteria where criterion.type.rawValue.contains("Streak") {
            if streak.currentStreak >= criterion.requiredCount {
                awardAchievement(type: criterion.type, level: criterion.level)
            }
        }
        
        // Check perfect day/week achievements
        if analytics.weeklyCompletionRate >= 1.0 {
            awardAchievement(type: .perfectWeek, level: .gold)
        } else if analytics.dailyCompletionRate >= 1.0 {
            awardAchievement(type: .perfectDay, level: .silver)
        }
    }
    
    private func awardAchievement(type: AchievementType, level: AchievementLevel) {
        // Check if already awarded
        if !achievements.contains(where: { $0.type == type && $0.level == level }) {
            let achievement = Achievement(type: type, level: level, dateEarned: Date(), progress: 1.0, isCompleted: true)
            achievements.append(achievement)
            calculatePoints() // Recalculate points after awarding achievement
            saveData()        // Save after awarding achievement
        }
    }
    
    private func loadData() {
        achievements = repository.loadAchievements()
        goalStreaks = repository.loadStreaks()
        criteria = repository.loadCriteria()
        calculatePoints() // Recalculate points after loading
    }
    
    private func saveData() {
        repository.saveAchievements(achievements)
        repository.saveStreaks(goalStreaks)
        repository.saveCriteria(criteria)
    }
    
    private func calculatePoints(for type: AchievementType, level: AchievementLevel) {
        let basePoints = 100
        let multiplier: Int
        
        switch level {
        case .bronze: multiplier = 1
        case .silver: multiplier = 2
        case .gold: multiplier = 3
        case .platinum: multiplier = 5
        }
        
        switch type {
        case .waterStreak: totalPoints += basePoints * multiplier
        case .mealStreak: totalPoints += (basePoints * 2) * multiplier
        case .breakStreak: totalPoints += basePoints * multiplier
        case .petCare: totalPoints += (basePoints * 3) * multiplier
        case .consistency: totalPoints += (basePoints * 2) * multiplier
        case .perfectDay: totalPoints += (basePoints * 2) * multiplier
        case .perfectWeek: totalPoints += (basePoints * 4) * multiplier
        }
        saveData() // Save after points update
    }
    
    private func calculatePoints() {
        var newTotal = 0
        for achievement in achievements where achievement.isCompleted {
            let basePoints = achievement.type.basePoints
            let multiplier = achievement.level.pointMultiplier
            newTotal += basePoints * multiplier
        }
        totalPoints = newTotal
        objectWillChange.send()
        saveData() // Save after recalculating total points
    }
    
    func updateAchievement(_ achievement: Achievement) {
        if let index = achievements.firstIndex(where: { $0.id == achievement.id }) {
            achievements[index] = achievement
            calculatePoints()
            saveData() // Save after updating achievement and recalculating points
        }
    }
    
    func addAchievement(_ achievement: Achievement) {
        achievements.append(achievement)
        calculatePoints()
        saveData() // Save after adding achievement and recalculating points
    }
    
    /// Call this method from app delegate or scene phase handlers to persist data
    /// before app goes to background or terminates.
    func persistNow() {
        saveData()
    }
}

// Add these extensions to support point calculations
extension AchievementType {
    var basePoints: Int {
        switch self {
        case .waterStreak: return 100
        case .mealStreak: return 150
        case .breakStreak: return 100
        case .petCare: return 200
        case .consistency: return 250
        case .perfectDay: return 300
        case .perfectWeek: return 500
        }
    }
}

extension AchievementLevel {
    var pointMultiplier: Int {
        switch self {
        case .bronze: return 1
        case .silver: return 2
        case .gold: return 3
        case .platinum: return 4
        }
    }
} 
