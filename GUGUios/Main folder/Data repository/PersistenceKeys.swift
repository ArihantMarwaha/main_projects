//
//  PersistenceKeys.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import Foundation
import Combine

extension Goal {
    // Add computed property for next available time
    var nextAvailableTime: Date {
        Calendar.current.date(byAdding: .second,
                            value: Int(intervalInSeconds),
                            to: startTime) ?? Date()
    }
}


// MARK: - Persistence Keys
private enum PersistenceKeys {
    static let goals = "goals"
    static let trackerStates = "trackerStates"
}

// MARK: - Tracker State
struct TrackerState: Codable {
    let goalId: UUID
    var entries: [GoalEntry]
    var isInCooldown: Bool
    var cooldownEndTime: Date
}
