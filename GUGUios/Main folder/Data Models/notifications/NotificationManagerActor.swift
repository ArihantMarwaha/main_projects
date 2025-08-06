//
//  NotificationManagerActor.swift
//  GUGUios
//
//  Original notification system with 5-minute throttling
//

import Foundation
import SwiftUI
import UserNotifications
import Combine

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isPermissionGranted = false
    @Published var notificationSettings: NotificationSettings = NotificationSettings.load() {
        didSet {
            notificationSettings.save()
        }
    }

    // Smart scheduling properties
    private var lastNotificationTimes: [String: Date] = [:]
    private var notificationThrottleInterval: TimeInterval = 300 // 5 minutes minimum between similar notifications
    private var dailyNotificationCount: [String: Int] = [:]
    private var maxDailyNotifications: [NotificationCategory: Int] = [
        .goalReminder: 8,
        .petState: 6,
        .petCheckIn: 3,
        .motivational: 4,
        .cooldownEnd: 20, // Allow many cooldown notifications
        .streak: 5,
        .dailySummary: 1,
        .general: 10
    ]
    
    // Notification queuing system to prevent bombardment
    private var lastGlobalNotificationTime: Date = Date(timeIntervalSince1970: 0)
    private var minimumGlobalNotificationInterval: TimeInterval = 60 // 1 minute minimum between ANY notifications
    private var notificationQueue: [(id: String, title: String, body: String, delay: TimeInterval, category: NotificationCategory, repeats: Bool)] = []
    private var isProcessingQueue = false

    private init() {
        checkPermissionStatus()
        setupDailyReset()
    }

    // MARK: - Permission Management

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isPermissionGranted = granted
            }
            return granted
        } catch {
            print("❌ Notification permission error: \(error)")
            return false
        }
    }

    private func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }

    private func setupDailyReset() {
        // Reset daily notification counts at midnight
        let calendar = Calendar.current
        let now = Date()

        // Calculate next midnight
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
        let nextMidnight = calendar.startOfDay(for: tomorrow)
        let timeToMidnight = nextMidnight.timeIntervalSinceNow

        // Schedule daily reset
        Timer.scheduledTimer(withTimeInterval: timeToMidnight, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.resetDailyNotificationCounts()
                self?.setupDailyReset() // Schedule next reset
            }
        }
    }

    private func resetDailyNotificationCounts() {
        dailyNotificationCount.removeAll()
        print("🔄 Reset daily notification counts")
    }

    // MARK: - Basic Notification Scheduling

    func scheduleNotification(
        id: String = UUID().uuidString,
        title: String, 
        body: String, 
        delay: TimeInterval,
        category: NotificationCategory = .general,
        repeats: Bool = false
    ) {
        guard isPermissionGranted else {
            print("⚠️ Notification permission not granted for: '\(title)'")
            checkPermissionStatus()
            return
        }

        // Check if we should throttle this notification
        if shouldThrottleNotification(category: category, title: title) {
            print("🚫 Throttling notification: \(title) (category: \(category.rawValue))")
            return
        }

        // Add to queue instead of scheduling immediately
        addToNotificationQueue(id: id, title: title, body: body, delay: delay, category: category, repeats: repeats)
    }
    
    private func addToNotificationQueue(
        id: String,
        title: String,
        body: String,
        delay: TimeInterval,
        category: NotificationCategory,
        repeats: Bool
    ) {
        let notification = (id: id, title: title, body: body, delay: delay, category: category, repeats: repeats)
        notificationQueue.append(notification)
        
        print("📤 Added to notification queue: '\(title)' (Queue size: \(notificationQueue.count))")
        
        // Start processing queue if not already processing
        if !isProcessingQueue {
            processNotificationQueue()
        }
    }
    
    private func processNotificationQueue() {
        guard !isProcessingQueue, !notificationQueue.isEmpty else { return }
        
        isProcessingQueue = true
        print("🔄 Processing notification queue (\(notificationQueue.count) items)")
        
        processNextNotificationInQueue()
    }
    
    private func processNextNotificationInQueue() {
        guard !notificationQueue.isEmpty else {
            isProcessingQueue = false
            print("✅ Notification queue processing complete")
            return
        }
        
        let now = Date()
        let timeSinceLastNotification = now.timeIntervalSince(lastGlobalNotificationTime)
        
        // Check if enough time has passed since last notification
        if timeSinceLastNotification >= minimumGlobalNotificationInterval {
            // Schedule the next notification immediately
            let notification = notificationQueue.removeFirst()
            scheduleNotificationImmediately(
                id: notification.id,
                title: notification.title,
                body: notification.body,
                delay: notification.delay,
                category: notification.category,
                repeats: notification.repeats
            )
            lastGlobalNotificationTime = now
            
            // Process next notification after minimum interval
            DispatchQueue.main.asyncAfter(deadline: .now() + minimumGlobalNotificationInterval) {
                self.processNextNotificationInQueue()
            }
        } else {
            // Wait for the remaining time before processing next notification
            let remainingWaitTime = minimumGlobalNotificationInterval - timeSinceLastNotification
            print("⏳ Waiting \(Int(remainingWaitTime))s before processing next queued notification")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingWaitTime) {
                self.processNextNotificationInQueue()
            }
        }
    }
    
    private func scheduleNotificationImmediately(
        id: String,
        title: String,
        body: String,
        delay: TimeInterval,
        category: NotificationCategory,
        repeats: Bool
    ) {
        // Adjust delay for quiet hours
        let adjustedDelay = adjustDelayForQuietHours(delay: delay)

        print("🔔 Scheduling notification: ID=\(id), Title='\(title)', Delay=\(adjustedDelay)s")

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category.rawValue
        content.userInfo = [
            "category": category.rawValue,
            "timestamp": Date().timeIntervalSince1970,
            "originalTitle": title
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: adjustedDelay, repeats: repeats)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            } else {
                print("✅ Scheduled notification: \(title)")

                // Track notification for throttling
                Task { @MainActor in
                    self.trackNotification(category: category, title: title)
                }
            }
        }
    }

    // MARK: - Smart Scheduling Logic

    private func shouldThrottleNotification(category: NotificationCategory, title: String) -> Bool {
        let now = Date()
        let categoryKey = category.rawValue
        let titleKey = "\(category.rawValue)-\(title)"

        // Check daily limit
        let dailyCount = dailyNotificationCount[categoryKey] ?? 0
        let maxDaily = maxDailyNotifications[category] ?? 5

        if dailyCount >= maxDaily {
            print("📊 Daily limit reached for \(categoryKey): \(dailyCount)/\(maxDaily)")
            return true
        }

        // Check throttle interval for similar notifications
        if let lastTime = lastNotificationTimes[titleKey] {
            let timeSinceLastNotification = now.timeIntervalSince(lastTime)
            if timeSinceLastNotification < notificationThrottleInterval {
                let remainingTime = notificationThrottleInterval - timeSinceLastNotification
                print("⏰ Throttling \(title): \(Int(remainingTime))s remaining")
                return true
            }
        }

        return false
    }

    private func adjustDelayForQuietHours(delay: TimeInterval) -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()
        let scheduledTime = now.addingTimeInterval(delay)

        let hour = calendar.component(.hour, from: scheduledTime)

        // Quiet hours: 10 PM to 8 AM (22:00 to 08:00)
        if hour >= 22 || hour < 8 {
            print("🤫 Notification scheduled during quiet hours")

            // If it's after 10 PM, delay until 8 AM next day
            if hour >= 22 {
                let nextMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: scheduledTime.addingTimeInterval(24 * 3600)) ?? scheduledTime
                let adjustedDelay = nextMorning.timeIntervalSinceNow
                print("🌅 Delaying notification until 8 AM: \(adjustedDelay)s from now")
                return max(adjustedDelay, delay)
            }

            // If it's before 8 AM, delay until 8 AM same day
            if hour < 8 {
                let thisMorning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: scheduledTime) ?? scheduledTime
                let adjustedDelay = thisMorning.timeIntervalSinceNow
                print("🌅 Delaying notification until 8 AM: \(adjustedDelay)s from now")
                return max(adjustedDelay, delay)
            }
        }

        return delay
    }

    private func trackNotification(category: NotificationCategory, title: String) {
        let now = Date()
        let categoryKey = category.rawValue
        let titleKey = "\(category.rawValue)-\(title)"

        // Update last notification time
        lastNotificationTimes[titleKey] = now

        // Update daily count
        dailyNotificationCount[categoryKey] = (dailyNotificationCount[categoryKey] ?? 0) + 1

        print("📊 Notification tracked: \(categoryKey) (\(dailyNotificationCount[categoryKey] ?? 0)/\(maxDailyNotifications[category] ?? 5))")
    }

    // MARK: - Goal Reminder Notifications

    func scheduleGoalReminder(goalTitle: String, targetCount: Int, currentProgress: Int) {
        guard notificationSettings.goalReminders else { return }

        let remaining = targetCount - currentProgress
        let title = "Goal Reminder"
        let body = "You have \(remaining) more \(goalTitle.lowercased()) entries to complete today! 🎯"

        scheduleNotification(
            id: "goal-reminder-\(goalTitle.replacingOccurrences(of: " ", with: "-").lowercased())",
            title: title,
            body: body,
            delay: notificationSettings.goalReminderInterval,
            category: .goalReminder
        )
    }

    func scheduleCustomGoalReminders(goalId: UUID, goalTitle: String, goalDescription: String, reminderTimes: [Date]) {
        guard !reminderTimes.isEmpty else {
            print("⚠️ No reminder times provided for goal: \(goalTitle)")
            return
        }

        print("📅 Scheduling \(reminderTimes.count) custom reminders for goal: \(goalTitle)")
        let calendar = Calendar.current
        let now = Date()

        for (index, reminderTime) in reminderTimes.enumerated() {
            // Extract time components from reminderTime
            let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
            // Create today's date with the same time
            let todayReminder = calendar.date(bySettingHour: components.hour ?? 9,
                                              minute: components.minute ?? 0,
                                              second: 0,
                                              of: now) ?? reminderTime
            let delay = todayReminder.timeIntervalSinceNow

            print("   Reminder \(index + 1): \(reminderTime) -> Today: \(todayReminder), delay: \(delay) seconds")

            if delay > 0 {
                // Schedule for today
                let title = goalTitle
                let body = goalDescription.isEmpty ? "Time to work on your goal! 🎯" : goalDescription

                print("   ✅ Scheduling for today: '\(title)' - '\(body)' in \(delay) seconds")

                scheduleNotification(
                    id: "custom-reminder-\(goalId.uuidString)-\(index)",
                    title: title,
                    body: body,
                    delay: delay,
                    category: .goalReminder
                )
            } else {
                // Schedule for tomorrow
                let tomorrowReminder = calendar.date(byAdding: .day, value: 1, to: todayReminder) ?? todayReminder
                let tomorrowDelay = tomorrowReminder.timeIntervalSinceNow

                print("   ⏰ Scheduling for tomorrow: '\(goalTitle)' in \(tomorrowDelay) seconds")

                scheduleNotification(
                    id: "custom-reminder-\(goalId.uuidString)-\(index)",
                    title: goalTitle,
                    body: goalDescription.isEmpty ? "Time to work on your goal! 🎯" : goalDescription,
                    delay: tomorrowDelay,
                    category: .goalReminder
                )
            }
        }
    }

    func cancelCustomGoalReminders(goalId: UUID) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let idsToCancel = requests
                .filter { $0.identifier.hasPrefix("custom-reminder-\(goalId.uuidString)") }
                .map { $0.identifier }

            center.removePendingNotificationRequests(withIdentifiers: idsToCancel)
        }
    }

    func scheduleGoalCooldownEnd(goalTitle: String, cooldownEndTime: Date) {
        guard notificationSettings.cooldownNotifications else { return }

        let delay = cooldownEndTime.timeIntervalSinceNow
        guard delay > 0 else { return }

        let title = "\(goalTitle) Ready!"
        let body = "Your cooldown is over. Time to log your next \(goalTitle.lowercased())! ⏰"

        scheduleNotification(
            id: "cooldown-end-\(goalTitle.replacingOccurrences(of: " ", with: "-").lowercased())",
            title: title,
            body: body,
            delay: delay,
            category: .cooldownEnd
        )
    }

    // MARK: - Pet Notifications

    func schedulePetCheckIn() {
        guard notificationSettings.petCheckIns else { return }

        let titles = [
            "Your pet misses you! 🐾",
            "Check on your furry friend! 🐱",
            "Pet care time! 🏠",
            "Your companion needs attention! ✨"
        ]

        let bodies = [
            "See how your pet is doing and give them some love!",
            "Your pet's happiness depends on your daily progress!",
            "Time to check in and see what your pet needs!",
            "Your pet is waiting for you to complete your goals!"
        ]

        let title = titles.randomElement() ?? titles[0]
        let body = bodies.randomElement() ?? bodies[0]

        scheduleNotification(
            id: "pet-checkin-daily",
            title: title,
            body: body,
            delay: notificationSettings.petCheckInInterval,
            category: .petCheckIn
        )
    }

    func schedulePetStateNotification(petState: String, petName: String) {
        guard notificationSettings.petStateAlerts else { return }

        let (title, body) = getPetStateMessage(state: petState, name: petName)

        scheduleNotification(
            id: "pet-state-\(petState.lowercased())",
            title: title,
            body: body,
            delay: 600, // 10 minutes delay to avoid spam
            category: .petState
        )
    }

    private func getPetStateMessage(state: String, name: String) -> (String, String) {
        let petName = name.isEmpty ? "Your pet" : name

        switch state.lowercased() {
        case "hungry":
            return ("\(petName) is hungry! 🍽️", "Complete your meal goals to feed \(petName) and boost their satisfaction!")
        case "sleepy":
            return ("\(petName) is getting sleepy! 😴", "Take some breaks to help \(petName) rest and recharge their energy!")
        case "passedout":
            return ("\(petName) is exhausted! 🥱", "Your pet needs urgent care! Complete your health goals to help them recover!")
        case "happy":
            return ("\(petName) is happy! 😊", "Great job! Your pet is thriving thanks to your consistent goal completion!")
        case "play":
            return ("\(petName) wants to play! 🎾", "Your pet is energetic and playful! Keep up the great work with your goals!")
        case "ideal":
            return ("\(petName) is in perfect health! ✨", "Excellent! Your pet is at their best thanks to your dedication to your goals!")
        default:
            return ("\(petName) needs attention! 🐾", "Check in on your pet and see how they're doing!")
        }
    }

    // MARK: - Enhanced Pet Notifications

    func scheduleStatSpecificPetNotification(statType: String, statValue: Int, petName: String) {
        guard notificationSettings.petStateAlerts else { return }

        let (title, body) = getStatSpecificMessage(statType: statType, statValue: statValue, petName: petName)

        // Only send urgent notifications for low stats
        guard statValue <= 30 else { return }

        scheduleNotification(
            id: "pet-stat-\(statType.lowercased())-urgent",
            title: title,
            body: body,
            delay: 900, // 15 minutes delay for stat-specific alerts to prevent spam
            category: .petState
        )
    }

    private func getStatSpecificMessage(statType: String, statValue: Int, petName: String) -> (String, String) {
        let petName = petName.isEmpty ? "Your pet" : petName

        switch statType.lowercased() {
        case "hydration":
            if statValue <= 20 {
                return ("\(petName) is very thirsty! 💧", "Urgent: Log your water intake to help \(petName) stay hydrated!")
            } else if statValue <= 30 {
                return ("\(petName) needs water! 💦", "Your pet's hydration is low. Drink some water to help them!")
            }
        case "satisfaction":
            if statValue <= 20 {
                return ("\(petName) is starving! 🍽️", "Urgent: Complete your meal goals to feed \(petName)!")
            } else if statValue <= 30 {
                return ("\(petName) is getting hungry! 🥗", "Your pet's satisfaction is low. Log a meal or snack!")
            }
        case "energy":
            if statValue <= 20 {
                return ("\(petName) is exhausted! 😫", "Urgent: Take a break to help \(petName) recover their energy!")
            } else if statValue <= 30 {
                return ("\(petName) is getting tired! 😴", "Your pet needs rest. Take a break to boost their energy!")
            }
        default:
            return ("\(petName) needs care! 🐾", "Check on your pet and see what they need!")
        }

        return ("\(petName) needs attention! 🐾", "Check in on your pet and see how they're doing!")
    }

    // MARK: - Motivational Notifications

    func scheduleMotivationalNotification() {
        guard notificationSettings.motivationalMessages else { return }

        let messages = [
            ("You've got this! 💪", "Every small step counts towards your bigger goals!"),
            ("Stay consistent! 🌟", "Your daily habits are building an amazing future!"),
            ("Progress check! 📊", "How are your goals coming along today?"),
            ("Motivation boost! 🚀", "You're stronger than yesterday. Keep going!"),
            ("Daily reminder! ⏰", "Small consistent actions lead to big results!"),
            ("You're amazing! ✨", "Your commitment to growth is inspiring!"),
            ("Keep it up! 🎯", "Every completed goal brings you closer to success!"),
            ("Believe in yourself! 🌈", "You have the power to achieve anything you set your mind to!")
        ]

        let (title, body) = messages.randomElement() ?? messages[0]

        scheduleNotification(
            id: "motivational-daily",
            title: title,
            body: body,
            delay: notificationSettings.motivationalInterval,
            category: .motivational
        )
    }

    func scheduleStreakNotification(goalTitle: String, streakDays: Int) {
        guard notificationSettings.streakNotifications else { return }

        let title = "Streak Alert! 🔥"
        let body = "You're on a \(streakDays)-day streak with \(goalTitle)! Keep the momentum going!"

        scheduleNotification(
            id: "streak-\(goalTitle.replacingOccurrences(of: " ", with: "-").lowercased())",
            title: title,
            body: body,
            delay: 3600, // 1 hour delay
            category: .streak
        )
    }

    // MARK: - Daily Summary Notifications

    func scheduleDailySummary(completedGoals: Int, totalGoals: Int, petHappiness: Int) {
        guard notificationSettings.dailySummary else { return }

        let (title, body) = generateRichDailySummary(
            completedGoals: completedGoals,
            totalGoals: totalGoals,
            petHappiness: petHappiness
        )

        // Schedule for 8 PM
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0

        guard let triggerDate = Calendar.current.date(from: components) else { return }
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = NotificationCategory.dailySummary.rawValue
        content.userInfo = [
            "category": NotificationCategory.dailySummary.rawValue,
            "completedGoals": completedGoals,
            "totalGoals": totalGoals,
            "petHappiness": petHappiness,
            "timestamp": Date().timeIntervalSince1970
        ]

        let request = UNNotificationRequest(identifier: "daily-summary", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleEnhancedDailySummary(
        completedGoals: Int,
        totalGoals: Int,
        petHappiness: Int,
        streakDays: Int = 0,
        waterGoalMet: Bool = false,
        mealsGoalMet: Bool = false,
        breaksGoalMet: Bool = false,
        meditationGoalMet: Bool = false
    ) {
        guard notificationSettings.dailySummary else { return }

        let (title, body) = generateEnhancedDailySummary(
            completedGoals: completedGoals,
            totalGoals: totalGoals,
            petHappiness: petHappiness,
            streakDays: streakDays,
            waterGoalMet: waterGoalMet,
            mealsGoalMet: mealsGoalMet,
            breaksGoalMet: breaksGoalMet,
            meditationGoalMet: meditationGoalMet
        )

        scheduleNotification(
            id: "enhanced-daily-summary",
            title: title,
            body: body,
            delay: calculateDelayUntil8PM(),
            category: .dailySummary
        )
    }

    private func generateRichDailySummary(completedGoals: Int, totalGoals: Int, petHappiness: Int) -> (String, String) {
        let completionRate = totalGoals > 0 ? Double(completedGoals) / Double(totalGoals) : 0.0

        let title: String
        let body: String

        switch completionRate {
        case 1.0:
            title = "Perfect Day! 🌟"
            body = "Amazing! You completed all \(totalGoals) goals today! Your pet is \(petHappiness)% happy and couldn't be prouder!"
        case 0.8...0.99:
            title = "Excellent Progress! 🎯"
            body = "Great work! You completed \(completedGoals)/\(totalGoals) goals (\(Int(completionRate * 100))%). Your pet's happiness: \(petHappiness)%"
        case 0.5...0.79:
            title = "Good Day! 👍"
            body = "Nice job! You completed \(completedGoals)/\(totalGoals) goals (\(Int(completionRate * 100))%). Your pet's happiness: \(petHappiness)%"
        case 0.1...0.49:
            title = "Keep Going! 💪"
            body = "You completed \(completedGoals)/\(totalGoals) goals today. Tomorrow's a fresh start! Pet happiness: \(petHappiness)%"
        default:
            title = "New Day Tomorrow! 🌅"
            body = "Today was challenging, but every journey has ups and downs. Your pet believes in you! Pet happiness: \(petHappiness)%"
        }

        return (title, body)
    }

    private func generateEnhancedDailySummary(
        completedGoals: Int,
        totalGoals: Int,
        petHappiness: Int,
        streakDays: Int,
        waterGoalMet: Bool,
        mealsGoalMet: Bool,
        breaksGoalMet: Bool,
        meditationGoalMet: Bool
    ) -> (String, String) {

        let completionRate = totalGoals > 0 ? Double(completedGoals) / Double(totalGoals) : 0.0
        let goalsMet = [waterGoalMet, mealsGoalMet, breaksGoalMet, meditationGoalMet].filter { $0 }.count

        let title: String
        var bodyComponents: [String] = []

        // Determine title based on performance
        switch completionRate {
        case 1.0:
            title = goalsMet == 4 ? "Perfect Day! 🌟" : "All Goals Complete! 🎯"
        case 0.8...0.99:
            title = "Excellent Day! ⭐"
        case 0.5...0.79:
            title = "Good Progress! 👍"
        case 0.1...0.49:
            title = "Keep Building! 💪"
        default:
            title = "Tomorrow's Fresh Start! 🌅"
        }

        // Main achievement
        bodyComponents.append("Goals: \(completedGoals)/\(totalGoals) complete (\(Int(completionRate * 100))%)")

        // Pet status
        let petEmoji = petHappiness >= 80 ? "😊" : petHappiness >= 60 ? "🙂" : petHappiness >= 40 ? "😐" : "😕"
        bodyComponents.append("Pet: \(petHappiness)% happiness \(petEmoji)")

        // Streak information
        if streakDays > 0 {
            let streakEmoji = streakDays >= 7 ? "🔥" : streakDays >= 3 ? "⚡" : "✨"
            bodyComponents.append("Streak: \(streakDays) days \(streakEmoji)")
        }

        // Individual goal highlights
        var highlights: [String] = []
        if waterGoalMet { highlights.append("💧 Hydrated") }
        if mealsGoalMet { highlights.append("🍽️ Well-fed") }
        if breaksGoalMet { highlights.append("😌 Rested") }
        if meditationGoalMet { highlights.append("🧘 Mindful") }

        if !highlights.isEmpty {
            bodyComponents.append("Today: \(highlights.joined(separator: ", "))")
        }

        let body = bodyComponents.joined(separator: " • ")
        return (title, body)
    }

    private func calculateDelayUntil8PM() -> TimeInterval {
        let calendar = Calendar.current
        let now = Date()

        // Try to schedule for 8 PM today
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        components.second = 0

        guard let targetTime = calendar.date(from: components) else { return 3600 }

        // If 8 PM has already passed today, schedule for 8 PM tomorrow
        if targetTime <= now {
            guard let tomorrowTargetTime = calendar.date(byAdding: .day, value: 1, to: targetTime) else { return 3600 }
            return tomorrowTargetTime.timeIntervalSinceNow
        }

        return targetTime.timeIntervalSinceNow
    }

    // MARK: - Utility Functions

    func cancelNotification(withId id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        clearNotificationQueue()
    }
    
    func clearNotificationQueue() {
        notificationQueue.removeAll()
        isProcessingQueue = false
        print("🗑️ Cleared notification queue")
    }

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

}

// MARK: - Supporting Types

enum NotificationCategory: String, CaseIterable {
    case general = "general"
    case goalReminder = "goal_reminder"
    case cooldownEnd = "cooldown_end"
    case petCheckIn = "pet_checkin"
    case petState = "pet_state"
    case motivational = "motivational"
    case streak = "streak"
    case dailySummary = "daily_summary"
}

struct NotificationSettings: Codable {
    var goalReminders: Bool = true
    var cooldownNotifications: Bool = true
    var petCheckIns: Bool = true
    var petStateAlerts: Bool = true
    var motivationalMessages: Bool = true
    var streakNotifications: Bool = true
    var dailySummary: Bool = true

    // Intervals (in seconds)
    var goalReminderInterval: TimeInterval = 3600 * 3 // 3 hours
    var petCheckInInterval: TimeInterval = 3600 * 6 // 6 hours
    var motivationalInterval: TimeInterval = 3600 * 4 // 4 hours

    // UserDefaults key
    private static let userDefaultsKey = "NotificationSettings"

    // Load settings from UserDefaults
    static func load() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            print("📱 Loading default notification settings")
            return NotificationSettings()
        }
        print("📱 Loaded notification settings from UserDefaults")
        return settings
    }

    // Save settings to UserDefaults
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.userDefaultsKey)
            print("📱 Saved notification settings to UserDefaults")
        } catch {
            print("❌ Failed to save notification settings: \(error)")
        }
    }
}