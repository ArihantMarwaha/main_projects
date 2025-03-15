import Foundation

@MainActor
struct PetAchievementTracker {
    static func checkAchievements(for pet: PetData, rewardSystem: RewardSystem) async {
        let today = Date()
        
        // Create daily data for achievement tracking
        let dailyData = DailyProgressData(
            id: UUID(),
            date: today,
            goalId: UUID(),
            completedCount: pet.dailyProgress,
            targetCount: 3,
            completionTime: [today]
        )
        
        // Create analytics for the achievement check
        let analytics = WeeklyAnalytics(
            id: UUID(),
            weekStartDate: Calendar.current.startOfWeek(),
            goalId: UUID(),
            dailyData: [dailyData]
        )
        
        // Check achievements based on pet state
        if pet.isInIdealState {
            rewardSystem.updateProgress(for: UUID(), analytics: analytics)
        }
        
        // Check consistency based on daily progress
        if pet.dailyProgress >= 3 {
            rewardSystem.updateProgress(for: UUID(), analytics: analytics)
        }
    }
    
    // Helper methods
    private static func determinePetCareLevel(_ pet: PetData) -> AchievementLevel {
        let avgStats = (pet.energy + pet.hydration + pet.satisfaction) / 3
        switch avgStats {
        case 90...100: return .platinum
        case 80..<90: return .gold
        case 70..<80: return .silver
        default: return .bronze
        }
    }
    
    private static func calculatePetCareProgress(_ pet: PetData) -> Double {
        Double((pet.energy + pet.hydration + pet.satisfaction) / 3) / 100.0
    }
} 
