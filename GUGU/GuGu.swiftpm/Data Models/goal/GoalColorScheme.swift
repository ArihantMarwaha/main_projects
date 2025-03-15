//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import SwiftUI

enum GoalColorScheme: String, Codable, CaseIterable {
    case blue, green, purple, orange, red
    
    var primary: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .orange: return .orange
        case .red: return .red
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [primary.opacity(0.5), primary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
