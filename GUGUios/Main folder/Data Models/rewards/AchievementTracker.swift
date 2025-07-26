import Foundation

@MainActor
class AchievementTracker {
    private var rewardSystem: RewardSystem
    
    init(rewardSystem: RewardSystem) {
        self.rewardSystem = rewardSystem
    }
    
    func trackWaterProgress(hydration: Int, streak: Int) {
        updateAchievement(.waterStreak, currentValue: hydration, streak: streak)
    }
    
    func trackMealProgress(satisfaction: Int, streak: Int) {
        updateAchievement(.mealStreak, currentValue: satisfaction, streak: streak)
    }
    
    func trackBreakProgress(energy: Int, streak: Int) {
        updateAchievement(.breakStreak, currentValue: energy, streak: streak)
    }
    
    func trackPetCare(petData: PetData) {
        let avgStats = (petData.energy + petData.hydration + petData.satisfaction) / 3
        updateAchievement(.petCare, currentValue: avgStats)
    }
    
    func trackConsistency(dailyProgress: Int, streak: Int) {
        updateAchievement(.consistency, currentValue: dailyProgress, streak: streak)
    }
    
    private func updateAchievement(
        _ type: AchievementType,
        currentValue: Int,
        streak: Int? = nil
    ) {
        // Get current achievement for this type
        guard var achievement = rewardSystem.achievements.first(where: { $0.type == type }) else {
            return
        }
        
        // Update progress based on the achievement criteria
        if streak != nil {
            achievement.updateProgress(newProgress: 0)
        } else {
            achievement.updateProgress(newProgress: 0)
        }
        
        // If completed, try to upgrade to next level
        if achievement.isCompleted {
            upgradeAchievement(type: type)
        }
        
        // Update the achievement in the reward system
        rewardSystem.updateAchievement(achievement)
    }
    
    private func upgradeAchievement(type: AchievementType) {
        guard let current = rewardSystem.achievements.first(where: { $0.type == type }),
              current.isCompleted else {
            return
        }
        
        let nextLevel: AchievementLevel? = {
            switch current.level {
            case .bronze: return .silver
            case .silver: return .gold
            case .gold: return .platinum
            case .platinum: return nil
            }
        }()
        
        if let nextLevel = nextLevel {
            let targetValue: Int = {
                switch type {
                case .waterStreak: return nextLevel.waterTargets
                case .mealStreak: return nextLevel.mealTargets
                case .breakStreak: return nextLevel.breakTargets
                case .petCare: return nextLevel.petCareTargets
                case .consistency: return nextLevel.consistencyTargets
                case .perfectDay: return nextLevel.consistencyTargets
                case .perfectWeek: return nextLevel.consistencyTargets
                }
            }()
            
            let newAchievement = Achievement(
                type: type,
                level: nextLevel,
                dateEarned: Date(),
                targetValue: targetValue
            )
            rewardSystem.addAchievement(newAchievement)
        }
    }
} 
