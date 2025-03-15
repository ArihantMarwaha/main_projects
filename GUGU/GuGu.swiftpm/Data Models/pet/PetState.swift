import SwiftUI
import PhotosUI

enum PetState {
    case happy
    case ideal
    case play
    case sleepy
    case hungry
    case passedout
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .ideal: return .green
        case .play: return .blue
        case .sleepy: return .gray
        case .hungry: return .orange
        case .passedout: return .red
        }
    }
    
    var animationFrames: [Image] {
        switch self {
        case .happy: return [PetAnimationImages.happy1, PetAnimationImages.happy2]
        case .ideal: return [PetAnimationImages.ideal1, PetAnimationImages.ideal2]
        case .play: return [PetAnimationImages.play1, PetAnimationImages.play2]
        case .sleepy: return [PetAnimationImages.sleepy1, PetAnimationImages.sleepy2]
        case .hungry: return [PetAnimationImages.hungry1, PetAnimationImages.hungry2]
        case .passedout: return [PetAnimationImages.passedout1, PetAnimationImages.passedout2]
        }
    }
} 
