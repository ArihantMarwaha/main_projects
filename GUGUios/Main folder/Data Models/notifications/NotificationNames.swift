import Foundation

extension Notification.Name {
    // Analytics
    static let analyticsDidUpdate = Notification.Name("com.app.analytics.didUpdate")
    
    // Goals
    static let goalProgressUpdated = Notification.Name("com.app.goals.progressUpdated")
    static let goalCooldownStarted = Notification.Name("com.app.goals.cooldownStarted")
    static let goalFullyCompleted = Notification.Name("com.app.goals.fullyCompleted")
    
    // Pet
    static let petStateUpdated = Notification.Name("com.app.pet.stateUpdated")
} 