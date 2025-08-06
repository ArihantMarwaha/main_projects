import Foundation
import SwiftUI
import Combine
import SwiftData

@MainActor
class PetActivityManager: ObservableObject {
    @MainActor @Published private(set) var petData: PetData
    private var swiftDataRepository: SwiftDataPetRepository?
    private var needsCheckTimer: Timer?
    private var isCleanedUp = false
    
    init(repository: SwiftDataPetRepository? = nil) {
        self.swiftDataRepository = repository
        
        // Load pet data from SwiftData or create default
        if let repository = repository,
           let sdPetData = repository.petData {
            self.petData = sdPetData.toLegacyPetData()
        } else {
            self.petData = PetData(
                name: "",
                birthday: Date(),
                dailyProgress: 0,
                lastWaterTime: Date().addingTimeInterval(-7200), // Start 2 hours ago
                lastMealTime: Date().addingTimeInterval(-7200),
                lastBreakTime: Date().addingTimeInterval(-7200)
            )
        }
        
        
        // Add observer for goal updates
        setupNotificationObservers()
        
        startNeedsCheckTimer()
        
        // Schedule periodic pet notifications with pet name
        Task {
            scheduleRecurringNotifications()
        }
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            forName: .goalProgressUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let goalTitle = notification.userInfo?["goalTitle"] as? String else { 
                print("⚠️ Invalid notification payload in PetActivityManager - missing goalTitle")
                print("⚠️ Available keys: \(notification.userInfo?.keys.map { String(describing: $0) } ?? [])")
                return 
            }
            
            print("🐾 PetActivityManager received goal update for: \(goalTitle)")
            // Already on main queue, can call directly
            self.updateProgress(for: goalTitle)
        }
    }
    
    // Update progress - now properly MainActor isolated
    @MainActor
    func updateProgress(for goalType: String) {
        print("🐾 PetActivityManager updating progress for: \(goalType)")
        
        do {
            withAnimation(.spring(response: 0.3)) {
            let now = Date()
            
            switch goalType {
            case "Water Intake":
                petData.lastWaterTime = now
                petData.hydration = 100
                
            case "Meals & Snacks":
                petData.lastMealTime = now
                petData.satisfaction = 100
                
            case "Take Breaks":
                petData.lastBreakTime = now
                petData.energy = 100
                
            default: break
            }
            
            
            petData.updateState()
            savePetData()
            objectWillChange.send()
            
            print("✅ PetActivityManager progress updated successfully")
        }
        } catch {
            print("❌ Error in PetActivityManager.updateProgress: \(error.localizedDescription)")
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
        
        
        // Schedule pet state notifications when state changes significantly
        if oldState != petData.state {
            Task {
                NotificationManager.shared.schedulePetStateNotification(
                    petState: petData.state.rawValue,
                    petName: petData.name
                )
            }
            
            // Post pet state updated notification
            NotificationCenter.default.post(
                name: .petStateUpdated,
                object: nil,
                userInfo: [
                    "oldState": oldState.rawValue,
                    "newState": petData.state.rawValue,
                    "petName": petData.name
                ]
            )
        }
        
        // Check for stat-specific notifications when stats drop significantly
        checkForStatSpecificNotifications(
            oldEnergy: oldEnergy,
            oldHydration: oldHydration,
            oldSatisfaction: oldSatisfaction
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
    
    private func checkForStatSpecificNotifications(oldEnergy: Int, oldHydration: Int, oldSatisfaction: Int) {
        // Check for significant drops in individual stats and send targeted notifications
        
        // Energy notifications - when energy drops below thresholds
        if oldEnergy > 30 && petData.energy <= 30 {
            Task {
                NotificationManager.shared.scheduleStatSpecificPetNotification(
                    statType: "energy",
                    statValue: petData.energy,
                    petName: petData.name
                )
            }
        }
        
        // Hydration notifications - when hydration drops below thresholds
        if oldHydration > 30 && petData.hydration <= 30 {
            Task {
                NotificationManager.shared.scheduleStatSpecificPetNotification(
                    statType: "hydration",
                    statValue: petData.hydration,
                    petName: petData.name
                )
            }
        }
        
        // Satisfaction notifications - when satisfaction drops below thresholds
        if oldSatisfaction > 30 && petData.satisfaction <= 30 {
            Task {
                NotificationManager.shared.scheduleStatSpecificPetNotification(
                    statType: "satisfaction",
                    statValue: petData.satisfaction,
                    petName: petData.name
                )
            }
        }
        
        // Critical state notifications - when any stat drops very low
        if petData.energy <= 20 || petData.hydration <= 20 || petData.satisfaction <= 20 {
            Task {
                let criticalStat = petData.energy <= 20 ? "energy" : 
                                  petData.hydration <= 20 ? "hydration" : "satisfaction"
                let criticalValue = petData.energy <= 20 ? petData.energy : 
                                   petData.hydration <= 20 ? petData.hydration : petData.satisfaction
                
                NotificationManager.shared.scheduleStatSpecificPetNotification(
                    statType: criticalStat,
                    statValue: criticalValue,
                    petName: petData.name
                )
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
    
    // Setup SwiftData repository
    func setupSwiftDataRepository(_ repository: SwiftDataPetRepository) {
        self.swiftDataRepository = repository
        
        // Load data from SwiftData if available
        if let sdPetData = repository.petData?.toLegacyPetData() {
            self.petData = sdPetData
        }
    }
    
    // Made internal for preview access
    @MainActor internal func savePetData() {
        if let swiftDataRepo = swiftDataRepository {
            // Save using SwiftData
            if let existingSDPetData = swiftDataRepo.petData {
                // Update existing pet data
                existingSDPetData.name = petData.name
                existingSDPetData.dailyProgress = petData.dailyProgress
                existingSDPetData.petState = petData.state
                existingSDPetData.energy = petData.energy
                existingSDPetData.hydration = petData.hydration
                existingSDPetData.satisfaction = petData.satisfaction
                existingSDPetData.happiness = petData.happiness
                existingSDPetData.stress = petData.stress
                existingSDPetData.lastWaterTime = petData.lastWaterTime
                existingSDPetData.lastMealTime = petData.lastMealTime
                existingSDPetData.lastBreakTime = petData.lastBreakTime
                existingSDPetData.waterStreak = petData.waterStreak
                existingSDPetData.mealStreak = petData.mealStreak
                existingSDPetData.breakStreak = petData.breakStreak
                
                try? swiftDataRepo.updatePetData()
            } else {
                // Create new pet data
                let sdPetData = SDPetData.fromLegacyPetData(petData)
                try? swiftDataRepo.createPetData(sdPetData)
            }
        }
        // No fallback - SwiftData only
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
    
    // Schedule recurring pet and motivational notifications
    private func scheduleRecurringNotifications() {
        Task {
            // Schedule pet check-in notifications with pet name
            NotificationManager.shared.schedulePetCheckIn()
            
            // Schedule motivational notifications
            NotificationManager.shared.scheduleMotivationalNotification()
        }
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

