import Foundation

/// UserDefaults key constants for type-safe access
struct UserDefaultsKeys {
    // MARK: - Authentication
    static let currentUserID = "currentUserID"
    static let isAuthenticated = "isAuthenticated"
    static let lastLoginDate = "lastLoginDate"
    
    // MARK: - User Preferences
    static let userPreferences = "userPreferences"
    static let notificationsEnabled = "notificationsEnabled"
    static let darkModeEnabled = "darkModeEnabled"
    static let languageCode = "languageCode"
    
    // MARK: - App State
    static let onboardingCompleted = "onboardingCompleted"
    static let appVersion = "appVersion"
    static let lastSyncDate = "lastSyncDate"
    
    // MARK: - Cache
    static let cachedPets = "cachedPets"
    static let cachedBookings = "cachedBookings"
    static let cachedUsers = "cachedUsers"
    
    // MARK: - Walker Specific
    static let walkerAvailability = "walkerAvailability"
    static let walkerServices = "walkerServices"
    static let walkerEarnings = "walkerEarnings"
    
    // MARK: - Owner Specific
    static let ownerPets = "ownerPets"
    static let ownerBookings = "ownerBookings"
    static let ownerFavorites = "ownerFavorites"
} 