import SwiftUI
import Combine

@MainActor
class GoalEditViewModel: ObservableObject {
    let goal: Goal
    @Published var title: String
    @Published var description: String
    @Published var targetCount: Int
    @Published var intervalHours: Int
    @Published var intervalMinutes: Int
    @Published var colorScheme: GoalColorScheme
    
    private let maxTargetCount = 50
    private let minTargetCount = 1
    
    init(goal: Goal) {
        self.goal = goal
        self.title = goal.title
        self.description = goal.description
        self.targetCount = goal.targetCount
        self.colorScheme = goal.colorScheme
        
        let hours = Int(goal.intervalInSeconds / 3600)
        let minutes = Int((goal.intervalInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
        self.intervalHours = hours
        self.intervalMinutes = minutes
    }
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        targetCount >= minTargetCount &&
        targetCount <= maxTargetCount
    }
    
    func incrementTarget() {
        guard targetCount < maxTargetCount else { return }
        targetCount += 1
    }
    
    func decrementTarget() {
        guard targetCount > minTargetCount else { return }
        targetCount -= 1
    }
    
    func saveChanges(using manager: GoalsManager, resetProgress: Bool) {
        let intervalInSeconds = Double(intervalHours * 3600 + intervalMinutes * 60)
        let updatedGoal = Goal(
            id: goal.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            targetCount: targetCount,
            intervalInSeconds: intervalInSeconds,
            colorScheme: colorScheme,
            startTime: resetProgress ? Date() : goal.startTime,
            isActive: goal.isActive,
            isDefault: goal.isDefault
        )
        
        withAnimation {
            manager.updateGoal(updatedGoal, resetProgress: resetProgress)
        }
    }
} 
