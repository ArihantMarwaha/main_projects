//
//  PetRepository.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import Foundation
import Foundation

class PetRepository {
    private let PET_DATA_KEY = "PET_DATA_KEY"
    private let PET_ACHIEVEMENTS_KEY = "PET_ACHIEVEMENTS_KEY"
    
    func savePetData(_ petData: PetData) {
        if let encoded = try? JSONEncoder().encode(petData) {
            UserDefaults.standard.set(encoded, forKey: PET_DATA_KEY)
        }
    }
    
    func loadPetData() -> PetData? {
        guard let data = UserDefaults.standard.data(forKey: PET_DATA_KEY),
              let decoded = try? JSONDecoder().decode(PetData.self, from: data)
        else {
            return nil
        }
        return decoded
    }
    
    func saveAchievements(_ achievements: [PetAchievement]) {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: PET_ACHIEVEMENTS_KEY)
        }
    }
    
    func loadAchievements() -> [PetAchievement] {
        guard let data = UserDefaults.standard.data(forKey: PET_ACHIEVEMENTS_KEY),
              let decoded = try? JSONDecoder().decode([PetAchievement].self, from: data)
        else {
            return []
        }
        return decoded
    }
}
