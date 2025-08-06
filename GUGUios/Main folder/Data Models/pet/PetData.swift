import Foundation
import SwiftUI

struct PetData: Codable {
    var name: String
    var birthday: Date
    var dailyProgress: Int
    var state: PetState = .ideal
    
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
    
    mutating func updateCharacteristics() {
        // Calculate hours elapsed since last actions directly
        let waterHoursSince = -lastWaterTime.timeIntervalSinceNow / 3600
        let mealHoursSince = -lastMealTime.timeIntervalSinceNow / 3600
        let breakHoursSince = -lastBreakTime.timeIntervalSinceNow / 3600
        
        // Calculate current values based on elapsed time
        hydration = calculateCurrentValue(
            hoursSince: waterHoursSince,
            threshold: DecayThreshold.water,
            decayRate: DecayRate.water
        )
        
        satisfaction = calculateCurrentValue(
            hoursSince: mealHoursSince,
            threshold: DecayThreshold.meal,
            decayRate: DecayRate.meal,
            minimumValue: 20  // Keep minimum satisfaction at 20%
        )
        
        energy = calculateCurrentValue(
            hoursSince: breakHoursSince,
            threshold: DecayThreshold.break_,
            decayRate: DecayRate.break_
        )
        
        updateState()
    }
    
    private func calculateCurrentValue(
        hoursSince: Double,
        threshold: Double,
        decayRate: Double,
        minimumValue: Int = 20
    ) -> Int {
        if hoursSince <= 0 {
            return 100 // Just completed
        }
        
        if hoursSince <= threshold {
            // Within threshold - gradual decline
            let decayProgress = hoursSince / threshold
            return max(minimumValue, Int(100.0 - (decayProgress * 30.0))) // Lose up to 30% within threshold
        } else {
            // Past threshold - faster decay
            let overtimeHours = hoursSince - threshold
            let baseValue = 70 // Starting from 70% after threshold
            let decayAmount = Int(overtimeHours * decayRate)
            return max(minimumValue, baseValue - decayAmount)
        }
    }
    
    mutating func logGoal(_ goalType: String) {
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
        
        updateCharacteristics()
    }
    
    mutating func updateState() {
        let h = hydration
        let s = satisfaction
        let e = energy
        
        // Calculate average status
        let avgStatus = (h + s + e) / 3
        
        switch (h, s, e, avgStatus) {
        case (let h, let s, let e, _) where h >= 75 && s >= 75 && e >= 75:
            state = .happy
            
        case (let h, let s, let e, _) where h >= 50 && s >= 50 && e >= 50:
            if e >= 70 {
                state = .play
            } else {
                state = .ideal
            }
            
        case (_, _, let e, _) where e <= 30:
            state = .passedout
            
        case (_, _, let e, _) where e <= 50:
            state = .sleepy
            
        case (_, let s, _, _) where s <= 40:
            state = .hungry
            
        case (let h, _, _, _) where h <= 40:
            state = .passedout
            
        default:
            state = .ideal
        }
    }
    
    // State transition thresholds
    struct Threshold {
        static let critical = 30  // Below this triggers critical states
        static let low = 40       // Below this triggers warning states
        static let medium = 50    // Minimum for ideal state
        static let good = 60      // Above this for positive states
        static let excellent = 75 // Above this for best state
    }
    
   
    
   
    
    enum PetState: String, Codable {
        case happy
        case ideal
        case play
        case sleepy
        case hungry
        case passedout
        
        var animationFrames: [Image] {
            switch self {
            case .happy: return [PetAnimationImages.happy1, PetAnimationImages.happy2]
            case .ideal: return [PetAnimationImages.ideal1, PetAnimationImages.ideal2]
            case .play: return [PetAnimationImages.play1, PetAnimationImages.play1]
            case .sleepy: return [PetAnimationImages.sleepy1, PetAnimationImages.sleepy2]
            case .hungry: return [PetAnimationImages.hungry1, PetAnimationImages.hungry2]
            case .passedout: return [PetAnimationImages.passedout1, PetAnimationImages.passedout2]
            }
        }
    }
    
    
    var mood: String {
        switch state {
        case .happy: return "Very Happy"
        case .ideal: return "Content"
        case .play: return "Playful"
        case .sleepy: return "Sleepy"
        case .hungry: return "Hungry"
        case .passedout: return "Passed Out"
        }
    }
    
    var isInIdealState: Bool {
        // Check if all stats are in a good range
        let goodRange = (65...100)
        return goodRange.contains(energy) &&
               goodRange.contains(hydration) &&
               goodRange.contains(satisfaction)
    }
   
    
   
}


// Decay thresholds (in hours)
struct DecayThreshold {
    static let water: Double = 1.0    // Start decay after 1 hour (matches cooldown)
    static let meal: Double = 3.0     // Start decay after 3 hours (matches cooldown)
    static let break_: Double = 2.0   // Start decay after 2 hours (matches cooldown)
}

// Decay rates (points per hour)
struct DecayRate {
    static let water: Double = 15.0   // Lose 15 points per hour (more gradual)
    static let meal: Double = 10.0    // Lose 10 points per hour (slower for longer cooldown)
    static let break_: Double = 12.0  // Lose 12 points per hour (moderate)
}
