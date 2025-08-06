//
//  SwiftDataPetRepository.swift
//  GUGUios
//
//  SwiftData repository for Pet data management
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class SwiftDataPetRepository: ObservableObject {
    private let modelContext: ModelContext
    
    @Published private(set) var petData: SDPetData?
    @Published private(set) var isLoading = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadPetData()
    }
    
    // MARK: - Pet Data Management
    
    func loadPetData() {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let descriptor = FetchDescriptor<SDPetData>()
            let petDataArray = try modelContext.fetch(descriptor)
            
            if let existingPetData = petDataArray.first {
                petData = existingPetData
            } else {
                // Create default pet data if none exists
                let defaultPetData = SDPetData()
                try createPetData(defaultPetData)
            }
        } catch {
            print("Failed to load pet data: \(error)")
            petData = nil
        }
    }
    
    func createPetData(_ petData: SDPetData) throws {
        modelContext.insert(petData)
        try modelContext.save()
        self.petData = petData
    }
    
    func updatePetData() throws {
        guard let petData = petData else { return }
        petData.updatedAt = Date()
        try modelContext.save()
    }
    
    func deletePetData() throws {
        guard let petData = petData else { return }
        modelContext.delete(petData)
        try modelContext.save()
        self.petData = nil
    }
    
    // MARK: - Pet State Management
    
    func updatePetState(_ newState: PetData.PetState) throws {
        guard let petData = petData else { return }
        petData.petState = newState
        try updatePetData()
    }
    
    func updatePetStats(happiness: Int? = nil, hydration: Int? = nil, energy: Int? = nil, satisfaction: Int? = nil, stress: Int? = nil) throws {
        guard let petData = petData else { return }
        petData.updateStats(happiness: happiness, hydration: hydration, energy: energy, satisfaction: satisfaction, stress: stress)
        try updatePetData()
    }
    
    func feedPet() throws {
        guard let petData = petData else { return }
        // Update meal time and satisfaction
        petData.lastMealTime = Date()
        petData.satisfaction = min(100, petData.satisfaction + 10)
        petData.happiness = min(100, petData.happiness + 5)
        try updatePetData()
    }
    
    func recordGoalInteraction(goalType: String) throws {
        guard let petData = petData else { return }
        petData.logGoal(goalType)
        try updatePetData()
    }
    
    func updateDaysSinceBirth() throws {
        guard let petData = petData else { return }
        
        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: petData.birthday, to: Date()).day ?? 0
        
        // Update daily progress based on age
        petData.dailyProgress = daysSince
        try updatePetData()
    }
    
  
    // MARK: - Pet Health Calculations
    
    func calculateCurrentHealth() -> Int {
        guard let petData = petData else { return 0 }
        
        // Calculate overall health based on hydration, satisfaction, and energy
        let overallHealth = (petData.hydration + petData.satisfaction + petData.energy) / 3
        return max(0, min(100, overallHealth))
    }
    
    func calculateCurrentHappiness() -> Int {
        guard let petData = petData else { return 0 }
        
        let timeSinceLastMeal = Date().timeIntervalSince(petData.lastMealTime)
        let hoursSinceMeal = timeSinceLastMeal / 3600
        
        // Decrease happiness based on time since last meal
        let happinessDecrease = min(Int(hoursSinceMeal / 2), 30)
        return max(0, petData.happiness - happinessDecrease)
    }
    
    func calculateCurrentEnergy() -> Int {
        guard let petData = petData else { return 0 }
        
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: Date())
        
        // Energy follows a daily cycle
        // High energy during day (6-22), low energy at night (22-6)
        let baseEnergy = petData.energy
        
        if currentHour >= 6 && currentHour <= 22 {
            return min(100, baseEnergy + 10) // Daytime boost
        } else {
            return max(20, baseEnergy - 20) // Nighttime reduction
        }
    }
    
    func updatePetStatusBasedOnTime() throws {
        guard let petData = petData else { return }
        
        let currentHealth = calculateCurrentHealth()
        let currentHappiness = calculateCurrentHappiness()
        let currentEnergy = calculateCurrentEnergy()
        
        // Update stats  
        petData.updateStats(
            happiness: currentHappiness,
            hydration: petData.hydration, // Keep current hydration
            energy: currentEnergy,
            satisfaction: petData.satisfaction // Keep current satisfaction
        )
        
        // Determine pet state based on stats
        let newState: PetData.PetState
        if currentHealth < 30 || currentHappiness < 30 {
            newState = .passedout
        } else if currentEnergy < 30 {
            newState = .sleepy
        } else if currentHappiness < 50 {
            newState = .hungry
        } else if currentHealth > 80 && currentHappiness > 80 && currentEnergy > 70 {
            newState = .happy
        } else {
            newState = .ideal
        }
        
        petData.petState = newState
        try updatePetData()
    }
    
    // MARK: - Statistics
    
    func getPetAge() -> Int {
        guard let petData = petData else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: petData.birthday, to: Date()).day ?? 0
    }
    
    func getDailyProgress() -> Int {
        return petData?.dailyProgress ?? 0
    }
    
    func getLastWaterTime() -> Date {
        return petData?.lastWaterTime ?? Date()
    }
    
    func getLastMealTime() -> Date {
        return petData?.lastMealTime ?? Date()
    }
    
    func getLastBreakTime() -> Date {
        return petData?.lastBreakTime ?? Date()
    }
    
    // MARK: - Compatibility Methods (for gradual migration)
    
    func toLegacyPetData() -> PetData? {
        return petData?.toLegacyPetData()
    }
    
    // MARK: - Backup and Export
    
    func exportPetData() throws -> Data {
        guard let petData = petData else {
            throw RepositoryError.invalidData
        }
        
        let exportData: [String: Any] = [
            "id": petData.id.uuidString,
            "name": petData.name,
            "birthday": ISO8601DateFormatter().string(from: petData.birthday),
            "dailyProgress": petData.dailyProgress,
            "currentState": petData.currentState,
            "energy": petData.energy,
            "hydration": petData.hydration,
            "satisfaction": petData.satisfaction,
            "happiness": petData.happiness,
            "stress": petData.stress,
            "lastWaterTime": ISO8601DateFormatter().string(from: petData.lastWaterTime),
            "lastMealTime": ISO8601DateFormatter().string(from: petData.lastMealTime),
            "lastBreakTime": ISO8601DateFormatter().string(from: petData.lastBreakTime),
            "waterStreak": petData.waterStreak,
            "mealStreak": petData.mealStreak,
            "breakStreak": petData.breakStreak,
            "createdAt": ISO8601DateFormatter().string(from: petData.createdAt),
            "updatedAt": ISO8601DateFormatter().string(from: petData.updatedAt)
        ]
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
}
