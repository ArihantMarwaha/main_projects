import Foundation
import SwiftData
import Combine

/// Repository manager for unified data access with caching and synchronization
class RepositoryManager: ObservableObject {
    static let shared = RepositoryManager()
    
    private let userDefaultsManager = UserDefaultsManager.shared
    private var modelContext: ModelContext?
    
    // Published properties for reactive updates
    @Published var currentUser: User?
    @Published var pets: [Pet] = []
    @Published var bookings: [Booking] = []
    @Published var users: [User] = []
    @Published var userPreferences: UserPreferences?
    
    // Cache management
    private var cacheExpiryTimes: [String: Date] = [:]
    private let cacheExpiryDuration: TimeInterval = 300 // 5 minutes
    
    // Published property for debug view
    @Published var debugAllUsers: [User] = []
    
    private init() {}
    
    // MARK: - Setup
    
    /// Set the SwiftData model context
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        print("🔧 RepositoryManager: ModelContext set")
    }
    
    // MARK: - User Management
    
    /// Create a new user
    @MainActor
    func createUser(email: String, name: String, userType: UserType) async throws -> User {
        guard let context = modelContext else {
            print("❌ RepositoryManager: No model context available")
            throw RepositoryError.noModelContext
        }
        
        print("🔧 RepositoryManager: Creating user with email: \(email)")
        
        // Check if user already exists
        let existingUser = try await getUserByEmail(email)
        if existingUser != nil {
            print("❌ RepositoryManager: User already exists with email: \(email)")
            throw RepositoryError.userAlreadyExists
        }
        
        let userModel = UserModel(
            email: email,
            name: name,
            address: "",
            userType: userType.rawValue,
            numberOfRatings: 0
        )
        
        print("🔧 RepositoryManager: Inserting user model with ID: \(userModel.id)")
        context.insert(userModel)
        try context.save()
        print("✅ RepositoryManager: User saved to SwiftData successfully")
        
        let user = userModel.toUser()
        
        // Update cache
        users.append(user)
        try await userDefaultsManager.storeCachedUsers(users)
        print("✅ RepositoryManager: User cached successfully")
        
        return user
    }
    
    /// Get user by email
    @MainActor
    func getUserByEmail(_ email: String) async throws -> User? {
        guard let context = modelContext else {
            print("❌ RepositoryManager: No model context available for getUserByEmail")
            throw RepositoryError.noModelContext
        }
        
        print("🔍 RepositoryManager: Searching for user with email: \(email)")
        
        let descriptor = FetchDescriptor<UserModel>(predicate: #Predicate { $0.email == email })
        let userModels = try context.fetch(descriptor)
        
        print("🔍 RepositoryManager: Found \(userModels.count) users with email: \(email)")
        
        if let userModel = userModels.first {
            let user = userModel.toUser()
            print("✅ RepositoryManager: User found - ID: \(user.id), Name: \(user.name)")
            return user
        } else {
            print("❌ RepositoryManager: No user found with email: \(email)")
            return nil
        }
    }
    
    /// Get user by ID
    @MainActor
    func getUserByID(_ id: String) async throws -> User? {
        guard let context = modelContext else {
            throw RepositoryError.noModelContext
        }
        
        let descriptor = FetchDescriptor<UserModel>(predicate: #Predicate { $0.id == id })
        let userModels = try context.fetch(descriptor)
        
        return userModels.first?.toUser()
    }
    
    /// Update user profile
    func updateUser(_ user: User) async throws {
        guard let context = modelContext else {
            throw RepositoryError.noModelContext
        }
        
        let descriptor = FetchDescriptor<UserModel>(predicate: #Predicate { $0.id == user.id })
        let userModels = try context.fetch(descriptor)
        
        guard let userModel = userModels.first else {
            throw RepositoryError.userNotFound
        }
        
        // Update user model
        userModel.name = user.name
        userModel.email = user.email
        userModel.phoneNumber = user.phoneNumber
        userModel.address = user.address
        userModel.profileImageURL = user.profileImageURL
        userModel.bio = user.bio
        userModel.hourlyRate = user.hourlyRate
        userModel.rating = user.rating
        userModel.numberOfRatings = user.numberOfRatings
        
        try context.save()
        
        // Update cache
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
        try await userDefaultsManager.storeCachedUsers(users)
        
        // Update current user if it's the same user
        if currentUser?.id == user.id {
            currentUser = user
        }
    }
    
    /// Get all users (with caching)
    func getAllUsers() async throws -> [User] {
        // Check cache first
        if !isCacheExpired(for: "users") {
            return users
        }
        
        guard let context = modelContext else {
            throw RepositoryError.noModelContext
        }
        
        let descriptor = FetchDescriptor<UserModel>()
        let userModels = try context.fetch(descriptor)
        
        users = userModels.map { $0.toUser() }
        
        // Update cache
        try await userDefaultsManager.storeCachedUsers(users)
        updateCacheExpiry(for: "users")
        
        return users
    }
    
    /// Get users by type
    func getUsersByType(_ userType: UserType) async throws -> [User] {
        let allUsers = try await getAllUsers()
        return allUsers.filter { $0.userType == userType }
    }
    
    // MARK: - Pet Management
    
    /// Create a new pet
    func createPet(name: String, breed: String, age: Int, notes: String?, ownerId: String) async throws -> Pet {
        let pet = Pet(
            id: UUID().uuidString,
            ownerId: ownerId,
            name: name,
            breed: breed,
            age: age,
            notes: notes
        )
        
        pets.append(pet)
        try await userDefaultsManager.storeCachedPets(pets)
        
        return pet
    }
    
    /// Get pets for owner
    func getPetsForOwner(_ ownerId: String) async throws -> [Pet] {
        let allPets = try await getAllPets()
        return allPets.filter { $0.ownerId == ownerId }
    }
    
    /// Get all pets (with caching)
    func getAllPets() async throws -> [Pet] {
        // Check cache first
        if !isCacheExpired(for: "pets") {
            return pets
        }
        
        // Load from UserDefaults cache
        if let cachedPets = try await userDefaultsManager.retrieveCachedPets() {
            pets = cachedPets
            updateCacheExpiry(for: "pets")
            return pets
        }
        
        return []
    }
    
    // MARK: - Booking Management
    
    /// Create a new booking
    func createBooking(
        ownerId: String,
        walkerId: String,
        petId: String,
        date: Date,
        duration: Int,
        serviceType: String,
        price: Double,
        notes: String? = nil
    ) async throws -> Booking {
        let booking = Booking(
            id: UUID().uuidString,
            ownerId: ownerId,
            walkerId: walkerId,
            petId: petId,
            date: date,
            duration: duration,
            serviceType: serviceType,
            status: .pending,
            price: price,
            notes: notes,
            isPaid: false,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        bookings.append(booking)
        try await userDefaultsManager.storeCachedBookings(bookings)
        
        return booking
    }
    
    /// Get bookings for user
    func getBookingsForUser(_ userId: String, userType: UserType) async throws -> [Booking] {
        let allBookings = try await getAllBookings()
        
        switch userType {
        case .owner:
            return allBookings.filter { $0.ownerId == userId }
        case .walker:
            return allBookings.filter { $0.walkerId == userId }
        case .admin:
            return allBookings
        }
    }
    
    /// Update booking status
    func updateBookingStatus(_ bookingId: String, newStatus: BookingStatus) async throws {
        guard let index = bookings.firstIndex(where: { $0.id == bookingId }) else {
            throw RepositoryError.bookingNotFound
        }
        
        bookings[index].status = newStatus
        bookings[index].updatedAt = Date()
        
        try await userDefaultsManager.storeCachedBookings(bookings)
    }
    
    /// Get all bookings (with caching)
    func getAllBookings() async throws -> [Booking] {
        // Check cache first
        if !isCacheExpired(for: "bookings") {
            return bookings
        }
        
        // Load from UserDefaults cache
        if let cachedBookings = try await userDefaultsManager.retrieveCachedBookings() {
            bookings = cachedBookings
            updateCacheExpiry(for: "bookings")
            return bookings
        }
        
        return []
    }
    
    // MARK: - User Preferences
    
    /// Get user preferences
    func getUserPreferences() async throws -> UserPreferences {
        if let preferences = userPreferences {
            return preferences
        }
        
        let preferences = try await userDefaultsManager.getUserPreferences()
        userPreferences = preferences
        return preferences
    }
    
    /// Update user preferences
    func updateUserPreferences(_ preferences: UserPreferences) async throws {
        try await userDefaultsManager.storeUserPreferences(preferences)
        userPreferences = preferences
    }
    
    // MARK: - Authentication
    
    /// Set current user
    func setCurrentUser(_ user: User) async {
        currentUser = user
        await userDefaultsManager.storeCurrentUserID(user.id)
        await userDefaultsManager.storeAuthenticationState(true)
        await userDefaultsManager.storeLastLoginDate(Date())
        // Also store email for sign-in purposes
        await userDefaultsManager.storeValue(user.email, forKey: "currentUserEmail")
    }
    
    /// Clear current user (logout)
    func clearCurrentUser() async {
        currentUser = nil
        await userDefaultsManager.clearUserData()
    }
    
    /// Restore session from stored user ID
    func restoreSession() async throws -> User? {
        // Try to restore by stored user ID first
        if let userID = await userDefaultsManager.retrieveCurrentUserID() {
            if let user = try await getUserByID(userID) {
                currentUser = user
                return user
            }
        }
        
        // If ID-based restoration fails, try email-based (for backward compatibility)
        if let email = await userDefaultsManager.retrieveValue(String.self, forKey: "currentUserEmail") {
            if let user = try await getUserByEmail(email) {
                // Update stored user ID to match the found user
                await userDefaultsManager.storeCurrentUserID(user.id)
                currentUser = user
                return user
            }
        }
        
        // Clear invalid session data
        await userDefaultsManager.clearUserData()
        return nil
    }
    
    /// Verify user credentials and sign in
    @MainActor
    func signInUser(email: String, password: String = "") async throws -> User {
        print("🔐 RepositoryManager: Attempting sign in for email: \(email)")
        
        guard let user = try await getUserByEmail(email) else {
            print("❌ RepositoryManager: User not found for sign in - email: \(email)")
            throw RepositoryError.userNotFound
        }
        
        print("✅ RepositoryManager: User found for sign in - ID: \(user.id), Name: \(user.name)")
        
        // In a real app, you would verify the password here
        // For now, we just check if the user exists
        
        await setCurrentUser(user)
        print("✅ RepositoryManager: User signed in successfully")
        return user
    }
    
    /// Debug method to list all users in the database
    @MainActor
    func debugListAllUsers() async {
        guard let context = modelContext else {
            print("❌ RepositoryManager: No model context for debug")
            return
        }
        
        print("🔍 RepositoryManager: Debug - Listing all users in database")
        
        do {
            let descriptor = FetchDescriptor<UserModel>()
            let userModels = try context.fetch(descriptor)
            
            print("📊 RepositoryManager: Found \(userModels.count) total users in database:")
            for (index, userModel) in userModels.enumerated() {
                print("  \(index + 1). ID: \(userModel.id), Email: \(userModel.email), Name: \(userModel.name), Type: \(userModel.userType)")
            }
        } catch {
            print("❌ RepositoryManager: Error listing users: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Cache Management
    
    /// Check if cache is expired
    private func isCacheExpired(for key: String) -> Bool {
        guard let expiryTime = cacheExpiryTimes[key] else {
            return true
        }
        return Date() > expiryTime
    }
    
    /// Update cache expiry time
    private func updateCacheExpiry(for key: String) {
        cacheExpiryTimes[key] = Date().addingTimeInterval(cacheExpiryDuration)
    }
    
    /// Clear all caches
    func clearAllCaches() async {
        pets = []
        bookings = []
        users = []
        userPreferences = nil
        cacheExpiryTimes.removeAll()
        await userDefaultsManager.clearCache()
    }
    
    /// Refresh all data from persistent storage
    func refreshAllData() async throws {
        // Clear cache expiry times to force refresh
        cacheExpiryTimes.removeAll()
        
        // Refresh all data
        _ = try await getAllUsers()
        _ = try await getAllPets()
        _ = try await getAllBookings()
        _ = try await getUserPreferences()
    }
    
    /// Export all users to a JSON file in the app's documents directory
    @MainActor
    func exportAllUsersToFile() async {
        guard let context = modelContext else {
            print("❌ RepositoryManager: No model context for export")
            return
        }
        do {
            let descriptor = FetchDescriptor<UserModel>()
            let userModels = try context.fetch(descriptor)
            let users = userModels.map { $0.toUser() }
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(users)
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("users_export.json")
            try data.write(to: url)
            print("✅ Exported all users to: \(url.path)")
        } catch {
            print("❌ Failed to export users: \(error.localizedDescription)")
        }
    }
    
    /// Load all users for debug view
    @MainActor
    func loadAllUsersForDebug() async {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<UserModel>()
            let userModels = try context.fetch(descriptor)
            debugAllUsers = userModels.map { $0.toUser() }
        } catch {
            debugAllUsers = []
        }
    }
    
    /// Create default profiles for a walker and a user (owner) if the user database is empty
    @MainActor
    func createDefaultProfilesIfNeeded() async {
        guard let context = modelContext else { return }
        do {
            let descriptor = FetchDescriptor<UserModel>()
            let userModels = try context.fetch(descriptor)
            if userModels.isEmpty {
                print("🟢 Creating default owner and walker profiles for testing...")
                let owner = UserModel(
                    email: "owner@test.com",
                    name: "Default Owner",
                    address: "123 Owner St",
                    userType: UserType.owner.rawValue,
                    numberOfRatings: 0
                )
                let walker = UserModel(
                    email: "walker@test.com",
                    name: "Default Walker",
                    address: "456 Walker Ave",
                    userType: UserType.walker.rawValue,
                    numberOfRatings: 0,
                    bio: "Experienced walker for all breeds.",
                    hourlyRate: 20.0
                )
                context.insert(owner)
                context.insert(walker)
                try context.save()
                print("✅ Default profiles created: owner@test.com, walker@test.com")
            } else {
                print("ℹ️ Users already exist, skipping default profile creation.")
            }
        } catch {
            print("❌ Failed to create default profiles: \(error.localizedDescription)")
        }
    }
    
    /// Insert demo bookings for the current user (for demo/testing)
    @MainActor
    func insertDemoBookings(for owner: User, pets: [Pet], walkers: [User]) async throws {
        guard !pets.isEmpty, !walkers.isEmpty else { return }
        let now = Date()
        let demoBookings: [Booking] = [
            // Upcoming
            Booking(id: UUID().uuidString, ownerId: owner.id, walkerId: walkers[0].id, petId: pets[0].id, date: now.addingTimeInterval(3600 * 24), duration: 60, serviceType: "Dog Walking", status: .confirmed, price: 20.0, notes: "Walk in the park", isPaid: true, createdAt: now, updatedAt: now),
            Booking(id: UUID().uuidString, ownerId: owner.id, walkerId: walkers[0].id, petId: pets[0].id, date: now.addingTimeInterval(3600 * 48), duration: 30, serviceType: "Pet Sitting", status: .pending, price: 15.0, notes: nil, isPaid: false, createdAt: now, updatedAt: now),
            // Recent Activity
            Booking(id: UUID().uuidString, ownerId: owner.id, walkerId: walkers[0].id, petId: pets[0].id, date: now.addingTimeInterval(-3600 * 24), duration: 60, serviceType: "Dog Walking", status: .completed, price: 20.0, notes: "", rating: 5, review: "Great walk!", isPaid: true, createdAt: now.addingTimeInterval(-3600 * 25), updatedAt: now.addingTimeInterval(-3600 * 23)),
            Booking(id: UUID().uuidString, ownerId: owner.id, walkerId: walkers[0].id, petId: pets[0].id, date: now.addingTimeInterval(-3600 * 48), duration: 30, serviceType: "Pet Sitting", status: .cancelled, price: 15.0, notes: nil, isPaid: false, createdAt: now.addingTimeInterval(-3600 * 49), updatedAt: now.addingTimeInterval(-3600 * 47))
        ]
        self.bookings.append(contentsOf: demoBookings)
        try await userDefaultsManager.storeCachedBookings(self.bookings)
    }
    
    /// Insert demo walkers if none exist (for demo/testing)
    @MainActor
    func insertDemoWalkersIfNeeded() async throws {
        let existingWalkers = users.filter { $0.userType == .walker }
        if existingWalkers.isEmpty {
            let demoWalker = User(
                id: UUID().uuidString,
                email: "walker_demo@demo.com",
                phoneNumber: nil,
                userType: .walker,
                name: "Demo Walker",
                address: "123 Walker Lane",
                profileImageURL: nil,
                rating: 5.0,
                numberOfRatings: 1,
                bio: "Demo walker for testing.",
                services: nil,
                hourlyRate: 20.0,
                documents: nil,
                availability: nil
            )
            users.append(demoWalker)
            try await userDefaultsManager.storeCachedUsers(users)
        }
    }
}

// MARK: - Error Types

enum RepositoryError: LocalizedError {
    case noModelContext
    case userNotFound
    case userAlreadyExists
    case bookingNotFound
    case petNotFound
    case invalidData
    case saveFailed(Error)
    case loadFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .noModelContext:
            return "No model context available"
        case .userNotFound:
            return "User not found"
        case .userAlreadyExists:
            return "User already exists"
        case .bookingNotFound:
            return "Booking not found"
        case .petNotFound:
            return "Pet not found"
        case .invalidData:
            return "Invalid data"
        case .saveFailed(let error):
            return "Failed to save data: \(error.localizedDescription)"
        case .loadFailed(let error):
            return "Failed to load data: \(error.localizedDescription)"
        }
    }
} 
