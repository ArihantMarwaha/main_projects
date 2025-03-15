//
//  File.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import Foundation

@MainActor
class CustomGoalCreatorViewModel: ObservableObject {
    @Published var template: CustomGoalTemplate
    @Published var intervalHours: Int = 0
    @Published var intervalMinutes: Int = 0
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private var goalsManager: GoalsManager
    private let maxTargetCount = 50
    private let minTargetCount = 1
    
    init(goalsManager: GoalsManager) {
        self.goalsManager = goalsManager
        self.template = CustomGoalTemplate()
        
        // Set initial interval values
        let hours = Int(template.intervalHours)
        let minutes = Int((template.intervalHours - Double(hours)) * 60)
        self.intervalHours = hours
        self.intervalMinutes = minutes
    }
    
    func updateGoalsManager(_ newManager: GoalsManager) {
        self.goalsManager = newManager
    }
    
    var isFormValid: Bool {
        !template.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        template.targetCount >= minTargetCount &&
        template.targetCount <= maxTargetCount
    }
    
    func incrementTarget() {
        guard template.targetCount < maxTargetCount else { return }
        template.targetCount += 1
    }
    
    func decrementTarget() {
        guard template.targetCount > minTargetCount else { return }
        template.targetCount -= 1
    }
    
    func saveGoal() async {
        guard isFormValid else {
            showErrorMessage()
            return
        }
        
        let goal = template.createGoal()
        goalsManager.addGoal(goal)
    }
    
    // Update template interval when hours or minutes change
    func updateInterval() {
        let totalHours = Double(intervalHours) + (Double(intervalMinutes) / 60.0)
        template.intervalHours = totalHours
    }
    
    private func showErrorMessage() {
        if template.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please enter a title for your goal"
        } else if template.targetCount < minTargetCount {
            errorMessage = "Target count must be at least \(minTargetCount)"
        } else if template.targetCount > maxTargetCount {
            errorMessage = "Target count cannot exceed \(maxTargetCount)"
        }
        showingError = true
    }
}
