import Foundation
import SwiftUI
import Combine

@MainActor
class PetActivityManager: ObservableObject {
    var achievementTracker: AchievementTracker { AchievementTracker(rewardSystem: rewardSystem) }
    @MainActor @Published private(set) var petData: PetData
    private let repository: PetRepository
    let rewardSystem: RewardSystem
    @MainActor @Published private(set) var progressionSystem: ProgressionSystem
    
    private var needsCheckTimer: Timer?
    private var isCleanedUp = false
    
    init(repository: PetRepository? = nil, rewardSystem: RewardSystem? = nil) {
        self.repository = repository ?? PetRepository()
        self.rewardSystem = rewardSystem ?? RewardSystem()
        self.progressionSystem = ProgressionSystem()
        self.petData = self.repository.loadPetData() ?? PetData(
            name: "",
            birthday: Date(),
            dailyProgress: 0,
            lastWaterTime: Date().addingTimeInterval(-7200), // Start 2 hours ago
            lastMealTime: Date().addingTimeInterval(-7200),
            lastBreakTime: Date().addingTimeInterval(-7200)
        )
        
        // Initialize reward system with default achievements if needed
        Task {
            await initializeRewards()
        }
        
        // Add observer for goal updates
        setupNotificationObservers()
        
        startNeedsCheckTimer()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .goalProgressUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let goalType = notification.userInfo?["goalType"] as? String else { return }
            
            Task { @MainActor in
                self.updateProgress(for: goalType)
            }
        }
    }
    
    // Make updateProgress nonisolated but wrap its implementation
    nonisolated func updateProgress(for goalType: String) {
        Task { @MainActor in
            self.updateProgressOnMain(for: goalType)
        }
    }
    
    // The actual implementation is MainActor-isolated
    @MainActor
    private func updateProgressOnMain(for goalType: String) {
        withAnimation(.spring(response: 0.3)) {
            let now = Date()
            
            switch goalType {
            case "Water Intake":
                petData.lastWaterTime = now
                petData.hydration = 100
                rewardSystem.updateProgress(
                    for: .waterStreak,
                    progress: Double(petData.hydration) / 100.0
                )
                
            case "Meals & Snacks":
                petData.lastMealTime = now
                petData.satisfaction = 100
                rewardSystem.updateProgress(
                    for: .mealStreak,
                    progress: Double(petData.satisfaction) / 100.0
                )
                
            case "Take Breaks":
                petData.lastBreakTime = now
                petData.energy = 100
                rewardSystem.updateProgress(
                    for: .breakStreak,
                    progress: Double(petData.energy) / 100.0
                )
                
            default: break
            }
            
            // Update overall achievements
            let avgStats = (petData.energy + petData.hydration + petData.satisfaction) / 3
            rewardSystem.updateProgress(
                for: .petCare,
                progress: Double(avgStats) / 100.0
            )
            
            rewardSystem.updateProgress(
                for: .consistency,
                progress: Double(petData.dailyProgress) / 3.0
            )
            
            petData.updateState()
            savePetData()
            objectWillChange.send()
        }
    }
    
    private func updateAchievement(_ type: AchievementType, level: AchievementLevel = .bronze) {
        let progress: Double
        switch type {
        case .waterStreak:
            progress = min(1.0, Double(petData.hydration) / 100.0)
        case .mealStreak:
            progress = min(1.0, Double(petData.satisfaction) / 100.0)
        case .breakStreak:
            progress = min(1.0, Double(petData.energy) / 100.0)
        case .petCare:
            let avgStats = Double(petData.energy + petData.hydration + petData.satisfaction) / 300.0
            progress = min(1.0, avgStats)
        case .consistency:
            progress = min(1.0, Double(petData.dailyProgress) / 3.0)
        default:
            progress = 1.0
        }
        
        rewardSystem.updateProgress(for: type, progress: progress, level: level)
    }
    
    private func initializeRewards() async {
        // Initialize basic achievements
        let defaultAchievements = [
            (type: AchievementType.waterStreak, level: AchievementLevel.bronze),
            (type: AchievementType.mealStreak, level: AchievementLevel.bronze),
            (type: AchievementType.breakStreak, level: AchievementLevel.bronze),
            (type: AchievementType.petCare, level: AchievementLevel.bronze),
            (type: AchievementType.consistency, level: AchievementLevel.bronze)
        ]
        
        for achievement in defaultAchievements {
            rewardSystem.updateProgress(
                for: achievement.type,
                progress: 0.0,
                level: achievement.level
            )
        }
    }
    
    // Called by timer to regularly update pet state based on elapsed time
    @MainActor
    internal func checkNeeds() {
        let oldState = petData.state
        let oldEnergy = petData.energy
        let oldHydration = petData.hydration
        let oldSatisfaction = petData.satisfaction
        
        petData.updateCharacteristics()
        
        // Update achievements based on current stats
        let avgStats = (petData.energy + petData.hydration + petData.satisfaction) / 3
        rewardSystem.updateProgress(
            for: .petCare,
            progress: Double(avgStats) / 100.0
        )
        
        if oldState != petData.state ||
           abs(oldEnergy - petData.energy) >= 5 ||
           abs(oldHydration - petData.hydration) >= 5 ||
           abs(oldSatisfaction - petData.satisfaction) >= 5 {
            withAnimation(.easeInOut(duration: 0.3)) {
                savePetData()
                objectWillChange.send()
            }
        }
    }
    
    // Start a timer to check pet state more frequently for smoother updates
    private func startNeedsCheckTimer() {
        needsCheckTimer?.invalidate()
        // Update every 2 seconds instead of 1 for better performance
        needsCheckTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.checkNeeds()
            }
        }
    }
    
    func setPetName(_ name: String) {
        Task { @MainActor in
            petData.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            savePetData()
        }
    }
    
    // Made internal for preview access
    @MainActor internal func savePetData() {
        repository.savePetData(petData)
    }
    
    nonisolated func cleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.performCleanup()
        }
    }
    
    @MainActor
    private func performCleanup() {
        if !isCleanedUp {
            needsCheckTimer?.invalidate()
            needsCheckTimer = nil
            isCleanedUp = true
        }
    }
    
    deinit {
        cleanup()
    }
    
    // Handle cooldown effects
    @MainActor func handleCooldownExpired(for goalId: UUID) {
        // When cooldown expires, we don't update the pet immediately
        // The needs system will naturally show deterioration based on timestamps
        savePetData()
    }
    
    func startCooldownMonitoring(for goalId: UUID, cooldownEndTime: Date) {
        Task {
            try? await Task.sleep(for: .seconds(cooldownEndTime.timeIntervalSinceNow))
            await MainActor.run {
                checkNeeds()
            }
        }
    }
    
    @MainActor
    func resetDailyProgress() {
        petData.dailyProgress = 0
        savePetData()
    }
    
    // Made internal for subclasses to modify pet data
    @MainActor internal func updatePetData(_ update: (inout PetData) -> Void) {
        withAnimation {
            update(&petData)
            savePetData()
        }
    }
}

