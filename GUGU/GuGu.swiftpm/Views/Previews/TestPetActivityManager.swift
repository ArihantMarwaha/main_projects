import SwiftUI
import Foundation

@MainActor
class TestPetActivityManager: PetActivityManager {
    private var timeMultiplier: Double = 60
    private var timer: Timer?
    private var isSimulationRunning = false
    
    override init(repository: PetRepository = PetRepository(), rewardSystem: RewardSystem = RewardSystem()) {
        super.init(repository: repository, rewardSystem: rewardSystem)
    }
    
    func startSimulation(multiplier: Double) {
        guard !isSimulationRunning else { return }
        timeMultiplier = multiplier
        isSimulationRunning = true
        startAcceleratedTime()
    }
    
    func pauseSimulation() {
        isSimulationRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func setTimeMultiplier(_ multiplier: Double) {
        timeMultiplier = multiplier
        if isSimulationRunning {
            startAcceleratedTime() // Restart timer with new multiplier
        }
    }
    
    private func startAcceleratedTime() {
        timer?.invalidate()
        
        // Capture values needed for the timer in local constants
        let currentMultiplier = timeMultiplier
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor [weak self] in
                guard let self = self,
                      self.isSimulationRunning else { return }
                
                // Simulate time passing
                let simulatedMinutes = (0.1 * currentMultiplier) / 60.0
                
                // Update timestamps to simulate time passing
                self.updatePetData { petData in
                    petData.lastWaterTime = petData.lastWaterTime.addingTimeInterval(-simulatedMinutes * 3600)
                    petData.lastMealTime = petData.lastMealTime.addingTimeInterval(-simulatedMinutes * 3600)
                    petData.lastBreakTime = petData.lastBreakTime.addingTimeInterval(-simulatedMinutes * 3600)
                }
                
                // Update pet state
                self.checkNeeds()
            }
        }
    }
    
    nonisolated override func cleanup() {
        Task { @MainActor in
            await self.performCleanup()
        }
    }
    
    @MainActor
    private func performCleanup() {
        pauseSimulation()
        super.cleanup()
    }
} 
