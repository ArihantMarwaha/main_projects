import Foundation
import Combine

/// Thread-safe UserDefaults manager with proper error handling
@MainActor
class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    private let queue = DispatchQueue(label: "com.petroom.userdefaults", qos: .userInitiated)
    
    private init() {}
    
    // MARK: - Generic Methods
    
    /// Safely store any Codable object
    func store<T: Codable>(_ value: T, forKey key: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    let data = try JSONEncoder().encode(value)
                    self.userDefaults.set(data, forKey: key)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: UserDefaultsError.encodingFailed(error))
                }
            }
        }
    }
    
    /// Safely retrieve any Codable object
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                guard let data = self.userDefaults.data(forKey: key) else {
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let value = try JSONDecoder().decode(type, from: data)
                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: UserDefaultsError.decodingFailed(error))
                }
            }
        }
    }
    
    /// Store simple value types
    func storeValue<T>(_ value: T, forKey key: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.userDefaults.set(value, forKey: key)
                continuation.resume()
            }
        }
    }
    
    /// Retrieve simple value types
    func retrieveValue<T>(_ type: T.Type, forKey key: String) async -> T? {
        await withCheckedContinuation { continuation in
            queue.async {
                let value = self.userDefaults.object(forKey: key) as? T
                continuation.resume(returning: value)
            }
        }
    }
    
    /// Remove value for key
    func removeValue(forKey key: String) async {
        await withCheckedContinuation { continuation in
            queue.async {
                self.userDefaults.removeObject(forKey: key)
                continuation.resume()
            }
        }
    }
    
    /// Check if key exists
    func hasValue(forKey key: String) async -> Bool {
        await withCheckedContinuation { continuation in
            queue.async {
                let exists = self.userDefaults.object(forKey: key) != nil
                continuation.resume(returning: exists)
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Store current user ID
    func storeCurrentUserID(_ userID: String) async {
        await storeValue(userID, forKey: UserDefaultsKeys.currentUserID)
    }
    
    /// Retrieve current user ID
    func retrieveCurrentUserID() async -> String? {
        await retrieveValue(String.self, forKey: UserDefaultsKeys.currentUserID)
    }
    
    /// Store authentication state
    func storeAuthenticationState(_ isAuthenticated: Bool) async {
        await storeValue(isAuthenticated, forKey: UserDefaultsKeys.isAuthenticated)
    }
    
    /// Retrieve authentication state
    func retrieveAuthenticationState() async -> Bool {
        await retrieveValue(Bool.self, forKey: UserDefaultsKeys.isAuthenticated) ?? false
    }
    
    /// Store last login date
    func storeLastLoginDate(_ date: Date) async {
        await storeValue(date, forKey: UserDefaultsKeys.lastLoginDate)
    }
    
    /// Retrieve last login date
    func retrieveLastLoginDate() async -> Date? {
        await retrieveValue(Date.self, forKey: UserDefaultsKeys.lastLoginDate)
    }
    
    /// Store current user email
    func storeCurrentUserEmail(_ email: String) async {
        await storeValue(email, forKey: "currentUserEmail")
    }
    
    /// Retrieve current user email
    func retrieveCurrentUserEmail() async -> String? {
        await retrieveValue(String.self, forKey: "currentUserEmail")
    }
    
    // MARK: - User Preferences Methods
    
    /// Store user preferences
    func storeUserPreferences(_ preferences: UserPreferences) async throws {
        try await store(preferences, forKey: UserDefaultsKeys.userPreferences)
    }
    
    /// Retrieve user preferences
    func retrieveUserPreferences() async throws -> UserPreferences? {
        try await retrieve(UserPreferences.self, forKey: UserDefaultsKeys.userPreferences)
    }
    
    /// Get or create default user preferences
    func getUserPreferences() async throws -> UserPreferences {
        if let preferences = try await retrieveUserPreferences() {
            return preferences
        } else {
            let defaultPreferences = UserPreferences()
            try await storeUserPreferences(defaultPreferences)
            return defaultPreferences
        }
    }
    
    // MARK: - Cache Methods
    
    /// Store cached pets
    func storeCachedPets(_ pets: [Pet]) async throws {
        try await store(pets, forKey: UserDefaultsKeys.cachedPets)
    }
    
    /// Retrieve cached pets
    func retrieveCachedPets() async throws -> [Pet]? {
        try await retrieve([Pet].self, forKey: UserDefaultsKeys.cachedPets)
    }
    
    /// Store cached bookings
    func storeCachedBookings(_ bookings: [Booking]) async throws {
        try await store(bookings, forKey: UserDefaultsKeys.cachedBookings)
    }
    
    /// Retrieve cached bookings
    func retrieveCachedBookings() async throws -> [Booking]? {
        try await retrieve([Booking].self, forKey: UserDefaultsKeys.cachedBookings)
    }
    
    /// Store cached users
    func storeCachedUsers(_ users: [User]) async throws {
        try await store(users, forKey: UserDefaultsKeys.cachedUsers)
    }
    
    /// Retrieve cached users
    func retrieveCachedUsers() async throws -> [User]? {
        try await retrieve([User].self, forKey: UserDefaultsKeys.cachedUsers)
    }
    
    // MARK: - App State Methods
    
    /// Store onboarding completion status
    func storeOnboardingCompleted(_ completed: Bool) async {
        await storeValue(completed, forKey: UserDefaultsKeys.onboardingCompleted)
    }
    
    /// Retrieve onboarding completion status
    func retrieveOnboardingCompleted() async -> Bool {
        await retrieveValue(Bool.self, forKey: UserDefaultsKeys.onboardingCompleted) ?? false
    }
    
    /// Store app version
    func storeAppVersion(_ version: String) async {
        await storeValue(version, forKey: UserDefaultsKeys.appVersion)
    }
    
    /// Retrieve app version
    func retrieveAppVersion() async -> String? {
        await retrieveValue(String.self, forKey: UserDefaultsKeys.appVersion)
    }
    
    // MARK: - Cleanup Methods
    
    /// Clear all cached data
    func clearCache() async {
        await removeValue(forKey: UserDefaultsKeys.cachedPets)
        await removeValue(forKey: UserDefaultsKeys.cachedBookings)
        await removeValue(forKey: UserDefaultsKeys.cachedUsers)
    }
    
    /// Clear all user data (for logout)
    func clearUserData() async {
        await removeValue(forKey: UserDefaultsKeys.currentUserID)
        await removeValue(forKey: UserDefaultsKeys.isAuthenticated)
        await removeValue(forKey: UserDefaultsKeys.lastLoginDate)
        await removeValue(forKey: "currentUserEmail")
        await removeValue(forKey: UserDefaultsKeys.userPreferences)
        await clearCache()
    }
    
    /// Clear all app data (for reset)
    func clearAllData() async {
        await clearUserData()
        await removeValue(forKey: UserDefaultsKeys.onboardingCompleted)
        await removeValue(forKey: UserDefaultsKeys.appVersion)
    }
}

// MARK: - Error Types

enum UserDefaultsError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case keyNotFound(String)
    case invalidDataType
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .keyNotFound(let key):
            return "Key not found: \(key)"
        case .invalidDataType:
            return "Invalid data type"
        }
    }
} 