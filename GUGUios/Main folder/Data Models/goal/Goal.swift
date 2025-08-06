//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation
import SwiftUI

struct Goal: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var targetCount: Int
    var intervalInSeconds: TimeInterval
    var colorScheme: GoalColorScheme
    var startTime: Date
    var isActive: Bool
    var isDefault: Bool
    var requiresSpecialInterface: Bool
    var hasCustomReminders: Bool
    var reminderTimes: [Date]
    
    init(id: UUID = UUID(),
         title: String,
         description: String = "",
         targetCount: Int,
         intervalInSeconds: TimeInterval,
         colorScheme: GoalColorScheme = .blue,
         startTime: Date = Date(),
         isActive: Bool = true,
         isDefault: Bool = false,
         requiresSpecialInterface: Bool = false,
         hasCustomReminders: Bool = false,
         reminderTimes: [Date] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.targetCount = targetCount
        self.intervalInSeconds = intervalInSeconds
        self.colorScheme = colorScheme
        self.startTime = startTime
        self.isActive = isActive
        self.isDefault = isDefault
        self.requiresSpecialInterface = requiresSpecialInterface
        self.hasCustomReminders = hasCustomReminders
        self.reminderTimes = reminderTimes
    }
    
    // Add custom Equatable implementation if needed
    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.targetCount == rhs.targetCount &&
        lhs.intervalInSeconds == rhs.intervalInSeconds &&
        lhs.colorScheme == rhs.colorScheme &&
        lhs.startTime == rhs.startTime &&
        lhs.isActive == rhs.isActive &&
        lhs.isDefault == rhs.isDefault &&
        lhs.requiresSpecialInterface == rhs.requiresSpecialInterface &&
        lhs.hasCustomReminders == rhs.hasCustomReminders &&
        lhs.reminderTimes == rhs.reminderTimes
    }
    
    var color: Color {
        Color(colorScheme.rawValue)
    }
    
    var sortOrder: Int {
        // Default goals come first (0), custom goals second (1)
        isDefault ? 0 : 1
    }
}


//for general useage 
struct TrackerConstants {
    static let hourInSeconds: TimeInterval = 3600
    static let dayInSeconds: TimeInterval = 86400
}



