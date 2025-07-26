//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import Combine

enum GoalCategory: String, Codable, CaseIterable {
    case health = "Health"
    case work = "Work"
    case personal = "Personal"
    case fitness = "Fitness"
    
    var systemImage: String {
        switch self {
        case .health: return "heart.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .fitness: return "figure.walk"
        }
    }
}


