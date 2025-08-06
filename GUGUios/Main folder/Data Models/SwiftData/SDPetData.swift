//
//  SDPetData.swift
//  GUGUios
//
//  SwiftData model for Pet persistence
//

import Foundation
import SwiftData

@Model
class SDPetData {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var birthday: Date
    var dailyProgress: Int
    var currentState: String // PetState raw value
    
    // Core characteristics (0-100)
    var energy: Int = 100
    var hydration: Int = 100
    var satisfaction: Int = 100
    var happiness: Int = 100
    var stress: Int = 0
    
    // Timestamps for tracking last goal completions
    var lastWaterTime: Date
    var lastMealTime: Date
    var lastBreakTime: Date
    
    // Goal completion tracking
    var waterStreak: Int = 0
    var mealStreak: Int = 0
    var breakStreak: Int = 0
    
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(),
         name: String = "Gugu",
         birthday: Date = Date(),
         dailyProgress: Int = 0,
         currentState: PetData.PetState = .ideal,
         energy: Int = 100,
         hydration: Int = 100,
         satisfaction: Int = 100,
         happiness: Int = 100,
         stress: Int = 0,
         lastWaterTime: Date = Date(),
         lastMealTime: Date = Date(),
         lastBreakTime: Date = Date(),
         waterStreak: Int = 0,
         mealStreak: Int = 0,
         breakStreak: Int = 0,
         ) {
        self.id = id
        self.name = name
        self.birthday = birthday
        self.dailyProgress = dailyProgress
        self.currentState = currentState.rawValue
        self.energy = energy
        self.hydration = hydration
        self.satisfaction = satisfaction
        self.happiness = happiness
        self.stress = stress
        self.lastWaterTime = lastWaterTime
        self.lastMealTime = lastMealTime
        self.lastBreakTime = lastBreakTime
        self.waterStreak = waterStreak
        self.mealStreak = mealStreak
        self.breakStreak = breakStreak
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // Convert to legacy PetData model for compatibility
    func toLegacyPetData() -> PetData {
        let state = PetData.PetState(rawValue: currentState) ?? .ideal
        
        return PetData(
            name: name,
            birthday: birthday,
            dailyProgress: dailyProgress,
            state: state,
            energy: energy,
            hydration: hydration,
            satisfaction: satisfaction,
            happiness: happiness,
            stress: stress,
            lastWaterTime: lastWaterTime,
            lastMealTime: lastMealTime,
            lastBreakTime: lastBreakTime,
            waterStreak: waterStreak,
            mealStreak: mealStreak,
            breakStreak: breakStreak
        )
    }
    
    // Create from legacy PetData model
    static func fromLegacyPetData(_ petData: PetData) -> SDPetData {
        return SDPetData(
            name: petData.name,
            birthday: petData.birthday,
            dailyProgress: petData.dailyProgress,
            currentState: petData.state,
            energy: petData.energy,
            hydration: petData.hydration,
            satisfaction: petData.satisfaction,
            happiness: petData.happiness,
            stress: petData.stress,
            lastWaterTime: petData.lastWaterTime,
            lastMealTime: petData.lastMealTime,
            lastBreakTime: petData.lastBreakTime,
            waterStreak: petData.waterStreak,
            mealStreak: petData.mealStreak,
            breakStreak: petData.breakStreak
        )
    }
    
    // Computed properties
    var petState: PetData.PetState {
        get { PetData.PetState(rawValue: currentState) ?? .ideal }
        set { 
            currentState = newValue.rawValue
            updatedAt = Date()
        }
    }
    
    
    // Helper methods
    func updateStats(happiness: Int? = nil, hydration: Int? = nil, energy: Int? = nil, satisfaction: Int? = nil, stress: Int? = nil) {
        if let happiness = happiness {
            self.happiness = max(0, min(100, happiness))
        }
        if let hydration = hydration {
            self.hydration = max(0, min(100, hydration))
        }
        if let energy = energy {
            self.energy = max(0, min(100, energy))
        }
        if let satisfaction = satisfaction {
            self.satisfaction = max(0, min(100, satisfaction))
        }
        if let stress = stress {
            self.stress = max(0, min(100, stress))
        }
        self.updatedAt = Date()
    }
    
    func logGoal(_ goalType: String) {
        switch goalType {
        case "Water Intake":
            if -lastWaterTime.timeIntervalSinceNow < 3600 { // Within last hour
                waterStreak = min(4, waterStreak + 1)
            } else {
                waterStreak = 1
            }
            lastWaterTime = Date()
            
        case "Meals & Snacks":
            if -lastMealTime.timeIntervalSinceNow < 7200 { // Within last 2 hours
                mealStreak = min(4, mealStreak + 1)
            } else {
                mealStreak = 1
            }
            lastMealTime = Date()
            
        case "Take Breaks":
            if -lastBreakTime.timeIntervalSinceNow < 7200 { // Within last 2 hours
                breakStreak = min(4, breakStreak + 1)
            } else {
                breakStreak = 1
            }
            lastBreakTime = Date()
            
        default:
            break
        }
        
        updatedAt = Date()
    }
    
}