//
//  NotificationDelegate.swift
//  GUGUios
//
//  Notification delegate to handle foreground notifications and user interactions
//

import Foundation
import UserNotifications
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // This method is called when a notification is delivered to a foreground app
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("📱 Notification received in foreground: \(notification.request.content.title)")
        
        // Show the notification even when the app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // This method is called when the user interacts with a notification
    @MainActor func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let notification = response.notification
        let content = notification.request.content
        
        print("🔔 User interacted with notification: \(content.title)")
        print("   Action: \(response.actionIdentifier)")
        print("   Category: \(content.categoryIdentifier)")
        
        // Handle different notification categories and user actions
        switch content.categoryIdentifier {
        case NotificationCategory.goalReminder.rawValue:
            handleGoalReminderNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.cooldownEnd.rawValue:
            handleCooldownEndNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.petCheckIn.rawValue:
            handlePetCheckInNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.petState.rawValue:
            handlePetStateNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.motivational.rawValue:
            handleMotivationalNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.streak.rawValue:
            handleStreakNotification(content, actionIdentifier: response.actionIdentifier)
        case NotificationCategory.dailySummary.rawValue:
            handleDailySummaryNotification(content, actionIdentifier: response.actionIdentifier)
        default:
            print("   No specific handler for category: \(content.categoryIdentifier)")
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Category Registration
    
    func registerNotificationCategories() {
        let categories: Set<UNNotificationCategory> = [
            createGoalReminderCategory(),
            createCooldownEndCategory(),
            createPetCheckInCategory(),
            createPetStateCategory(),
            createMotivationalCategory(),
            createStreakCategory(),
            createDailySummaryCategory(),
            createGeneralCategory()
        ]
        
        UNUserNotificationCenter.current().setNotificationCategories(categories)
        print("✅ Registered \(categories.count) notification categories")
    }
    
    // MARK: - Category Creation
    
    private func createGoalReminderCategory() -> UNNotificationCategory {
        let logNowAction = UNNotificationAction(
            identifier: "LOG_NOW",
            title: "Log Now",
            options: [.foreground]
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER",
            title: "Remind Later",
            options: []
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.goalReminder.rawValue,
            actions: [logNowAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createCooldownEndCategory() -> UNNotificationCategory {
        let logNowAction = UNNotificationAction(
            identifier: "LOG_NOW",
            title: "Log Now",
            options: [.foreground]
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.cooldownEnd.rawValue,
            actions: [logNowAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createPetCheckInCategory() -> UNNotificationCategory {
        let checkPetAction = UNNotificationAction(
            identifier: "CHECK_PET",
            title: "Check Pet",
            options: [.foreground]
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.petCheckIn.rawValue,
            actions: [checkPetAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createPetStateCategory() -> UNNotificationCategory {
        let checkPetAction = UNNotificationAction(
            identifier: "CHECK_PET",
            title: "Check Pet",
            options: [.foreground]
        )
        
        let helpPetAction = UNNotificationAction(
            identifier: "HELP_PET",
            title: "Help Pet",
            options: [.foreground]
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.petState.rawValue,
            actions: [checkPetAction, helpPetAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createMotivationalCategory() -> UNNotificationCategory {
        let viewProgressAction = UNNotificationAction(
            identifier: "VIEW_PROGRESS",
            title: "View Progress",
            options: [.foreground]
        )
        
        let motivateAction = UNNotificationAction(
            identifier: "STAY_MOTIVATED",
            title: "Thanks!",
            options: []
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.motivational.rawValue,
            actions: [viewProgressAction, motivateAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createStreakCategory() -> UNNotificationCategory {
        let viewStreakAction = UNNotificationAction(
            identifier: "VIEW_STREAK",
            title: "View Streak",
            options: [.foreground]
        )
        
        let keepGoingAction = UNNotificationAction(
            identifier: "KEEP_GOING",
            title: "Keep Going!",
            options: []
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.streak.rawValue,
            actions: [viewStreakAction, keepGoingAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createDailySummaryCategory() -> UNNotificationCategory {
        let viewSummaryAction = UNNotificationAction(
            identifier: "VIEW_SUMMARY",
            title: "View Summary",
            options: [.foreground]
        )
        
        let planTomorrowAction = UNNotificationAction(
            identifier: "PLAN_TOMORROW",
            title: "Plan Tomorrow",
            options: [.foreground]
        )
        
        return UNNotificationCategory(
            identifier: NotificationCategory.dailySummary.rawValue,
            actions: [viewSummaryAction, planTomorrowAction],
            intentIdentifiers: [],
            options: []
        )
    }
    
    private func createGeneralCategory() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: NotificationCategory.general.rawValue,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
    }
    
    // MARK: - Notification Handlers
    
    @MainActor private func handleGoalReminderNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("🎯 Handling goal reminder notification with action: \(actionIdentifier)")
        
        if let goalTitle = content.userInfo["goalTitle"] as? String {
            print("   Goal: \(goalTitle)")
        }
        
        switch actionIdentifier {
        case "LOG_NOW":
            print("   User wants to log now - opening goal tracker")
            // TODO: Navigate to goal logging interface
        case "REMIND_LATER":
            print("   User wants reminder later - scheduling follow-up")
            scheduleFollowUpReminder(for: content)
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening main app")
        default:
            break
        }
    }
    
    private func handleCooldownEndNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("⏰ Handling cooldown end notification with action: \(actionIdentifier)")
        
        if let goalTitle = content.userInfo["goalTitle"] as? String {
            print("   Goal: \(goalTitle)")
        }
        
        switch actionIdentifier {
        case "LOG_NOW":
            print("   User wants to log now - opening goal tracker")
            // TODO: Navigate to specific goal tracker
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening goal tracker")
        default:
            break
        }
    }
    
    private func handlePetCheckInNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("🐾 Handling pet check-in notification with action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "CHECK_PET":
            print("   User wants to check pet - opening pet view")
            // TODO: Navigate to pet view
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening pet view")
        default:
            break
        }
    }
    
    private func handlePetStateNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("🐕 Handling pet state notification with action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "CHECK_PET":
            print("   User wants to check pet - opening pet view")
            // TODO: Navigate to pet view
        case "HELP_PET":
            print("   User wants to help pet - opening relevant goal tracker")
            // TODO: Navigate to relevant goal based on pet's needs
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening pet view")
        default:
            break
        }
    }
    
    private func handleMotivationalNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("💪 Handling motivational notification with action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "VIEW_PROGRESS":
            print("   User wants to view progress - opening dashboard")
            // TODO: Navigate to progress dashboard
        case "STAY_MOTIVATED":
            print("   User acknowledged motivation - scheduling next motivational message")
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening main app")
        default:
            break
        }
    }
    
    private func handleStreakNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("🔥 Handling streak notification with action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "VIEW_STREAK":
            print("   User wants to view streak - opening streak details")
            // TODO: Navigate to streak/achievement view
        case "KEEP_GOING":
            print("   User motivated to keep going!")
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening achievement view")
        default:
            break
        }
    }
    
    private func handleDailySummaryNotification(_ content: UNNotificationContent, actionIdentifier: String) {
        print("📊 Handling daily summary notification with action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "VIEW_SUMMARY":
            print("   User wants to view summary - opening daily summary")
            // TODO: Navigate to daily summary view
        case "PLAN_TOMORROW":
            print("   User wants to plan tomorrow - opening goal planning")
            // TODO: Navigate to goal planning interface
        case UNNotificationDefaultActionIdentifier:
            print("   User tapped notification - opening daily summary")
        default:
            break
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor private func scheduleFollowUpReminder(for content: UNNotificationContent) {
        // Schedule a follow-up reminder in 1 hour
        let followUpDelay: TimeInterval = 3600 // 1 hour
        
        NotificationManager.shared.scheduleNotification(
            id: "followup-\(Date().timeIntervalSince1970)",
            title: content.title,
            body: "Follow-up reminder: \(content.body)",
            delay: followUpDelay,
            category: .goalReminder
        )
        
        print("   Scheduled follow-up reminder in 1 hour")
    }
}
