import Foundation

/// User preferences and settings
struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    var languageCode: String
    var pushNotifications: PushNotificationSettings
    var privacySettings: PrivacySettings
    
    init() {
        self.notificationsEnabled = true
        self.darkModeEnabled = false
        self.languageCode = "en"
        self.pushNotifications = PushNotificationSettings()
        self.privacySettings = PrivacySettings()
    }
}

/// Push notification settings
struct PushNotificationSettings: Codable {
    var bookingReminders: Bool
    var newMessages: Bool
    var earningsUpdates: Bool
    var systemUpdates: Bool
    
    init() {
        self.bookingReminders = true
        self.newMessages = true
        self.earningsUpdates = true
        self.systemUpdates = false
    }
}

/// Privacy settings
struct PrivacySettings: Codable {
    var profileVisibility: ProfileVisibility
    var locationSharing: Bool
    var contactInfoSharing: Bool
    
    init() {
        self.profileVisibility = .public
        self.locationSharing = false
        self.contactInfoSharing = true
    }
}

/// Profile visibility options
enum ProfileVisibility: String, Codable, CaseIterable {
    case `public` = "public"
    case friendsOnly = "friends_only"
    case private_ = "private"
    
    var displayName: String {
        switch self {
        case .public: return "Public"
        case .friendsOnly: return "Friends Only"
        case .private_: return "Private"
        }
    }
} 