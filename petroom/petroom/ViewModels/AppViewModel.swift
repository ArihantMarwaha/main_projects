import Foundation
import SwiftData
import SwiftUI
import Combine

/// Main view model for managing app-wide data and state
class AppViewModel: ObservableObject {
    /// Repository manager for data operations
    private let repositoryManager = RepositoryManager.shared
    
    /// Published properties for reactive UI updates
    @Published var pets: [Pet] = []
    @Published var bookings: [Booking] = []
    @Published var users: [User] = []
    @Published var userPreferences: UserPreferences?
    @Published var isLoading = false
    @Published var error: String?
    
    init() {}
    
    // MARK: - Setup
    
    /// Set the model context (call this from ContentView or App)
    func setModelContext(_ context: ModelContext) {
        repositoryManager.setModelContext(context)
    }
    
    // MARK: - Pet Management
    
    /// Adds a new pet to the system
    @MainActor
    func addPet(name: String, breed: String, age: Int, notes: String?, ownerId: String) async throws {
        isLoading = true
        error = nil
        
        do {
            let pet = try await repositoryManager.createPet(
            name: name,
            breed: breed,
            age: age,
                notes: notes,
                ownerId: ownerId
            )
            pets.append(pet)
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Retrieves all pets for a specific owner
    func getPetsForOwner(ownerId: String) async throws -> [Pet] {
        return try await repositoryManager.getPetsForOwner(ownerId)
    }
    
    /// Load all pets
    @MainActor
    func loadPets() async throws {
        pets = try await repositoryManager.getAllPets()
    }
    
    // MARK: - Booking Management
    
    /// Creates a new booking in the system
    @MainActor
    func createBooking(
        ownerId: String,
        walkerId: String,
        petId: String,
        date: Date,
        duration: Int,
        serviceType: String,
        price: Double,
        notes: String? = nil
    ) async throws {
        isLoading = true
        error = nil
        
        do {
            let booking = try await repositoryManager.createBooking(
            ownerId: ownerId,
            walkerId: walkerId,
            petId: petId,
            date: date,
            duration: duration,
            serviceType: serviceType,
            price: price,
                notes: notes
            )
            bookings.append(booking)
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Retrieves bookings for a specific user based on their role
    func getBookingsForUser(userId: String, userType: UserType) async throws -> [Booking] {
        return try await repositoryManager.getBookingsForUser(userId, userType: userType)
    }
    
    /// Updates the status of a booking
    @MainActor
    func updateBookingStatus(bookingId: String, newStatus: BookingStatus) async throws {
        try await repositoryManager.updateBookingStatus(bookingId, newStatus: newStatus)
        
        // Update local array
        if let index = bookings.firstIndex(where: { $0.id == bookingId }) {
            bookings[index].status = newStatus
            bookings[index].updatedAt = Date()
        }
    }
    
    /// Load all bookings
    @MainActor
    func loadBookings() async throws {
        bookings = try await repositoryManager.getAllBookings()
    }
    
    // MARK: - User Management
    
    /// Retrieves users, optionally filtered by type
    func getUsers(userType: UserType? = nil) async throws -> [User] {
        if let type = userType {
            return try await repositoryManager.getUsersByType(type)
        } else {
            return try await repositoryManager.getAllUsers()
        }
    }
    
    /// Updates a user's rating
    @MainActor
    func updateUserRating(userId: String, newRating: Int) async throws {
        guard let user = users.first(where: { $0.id == userId }) else {
            throw RepositoryError.userNotFound
        }
        
            let currentRating = user.rating ?? 0
            let currentCount = user.numberOfRatings
            
            let newTotalRating = currentRating + Double(newRating)
            let newCount = currentCount + 1
            
        var updatedUser = user
        updatedUser.rating = newTotalRating
        updatedUser.numberOfRatings = newCount
        
        try await repositoryManager.updateUser(updatedUser)
        
        // Update local array
        if let index = users.firstIndex(where: { $0.id == userId }) {
            users[index] = updatedUser
        }
    }
    
    /// Load all users
    @MainActor
    func loadUsers() async throws {
        users = try await repositoryManager.getAllUsers()
    }
    
    // MARK: - User Preferences
    
    /// Load user preferences
    @MainActor
    func loadUserPreferences() async throws {
        userPreferences = try await repositoryManager.getUserPreferences()
    }
    
    /// Update user preferences
    @MainActor
    func updateUserPreferences(_ preferences: UserPreferences) async throws {
        try await repositoryManager.updateUserPreferences(preferences)
        userPreferences = preferences
    }
    
    // MARK: - Data Loading
    
    /// Load all data
    @MainActor
    func loadAllData() async throws {
        isLoading = true
        error = nil
        
        do {
            async let petsTask = repositoryManager.getAllPets()
            async let bookingsTask = repositoryManager.getAllBookings()
            async let usersTask = repositoryManager.getAllUsers()
            async let preferencesTask = repositoryManager.getUserPreferences()
            
            let (petsResult, bookingsResult, usersResult, preferencesResult) = try await (petsTask, bookingsTask, usersTask, preferencesTask)
            
            self.pets = petsResult
            self.bookings = bookingsResult
            self.users = usersResult
            self.userPreferences = preferencesResult
            
            isLoading = false
        } catch {
            self.error = error.localizedDescription
            isLoading = false
        }
    }
    
    /// Refresh all data
    @MainActor
    func refreshAllData() async throws {
        try await repositoryManager.refreshAllData()
        try await loadAllData()
    }
    
    // MARK: - Helper Methods
    
    /// Formats a number as currency
    func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    /// Formats a date for display
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Cache Management
    
    /// Clear all caches
    @MainActor
    func clearAllCaches() async {
        await repositoryManager.clearAllCaches()
        pets = []
        bookings = []
        users = []
        userPreferences = nil
    }
}

// MARK: - Preview Support

extension AppViewModel {
    /// Preview instance with mock data for testing
    static var preview: AppViewModel {
        let viewModel = AppViewModel()
        viewModel.pets = [
            Pet(id: "pet1", ownerId: "owner1", name: "Buddy", breed: "Golden Retriever", age: 3, notes: "Very friendly"),
            Pet(id: "pet2", ownerId: "owner1", name: "Fluffy", breed: "Persian Cat", age: 2, notes: "Loves to sleep")
        ]
        viewModel.bookings = [
            Booking(
                id: "booking1",
                ownerId: "owner1",
                walkerId: "walker1",
                petId: "pet1",
                date: Date().addingTimeInterval(86400), // Tomorrow
                duration: 60,
                serviceType: "Dog Walking",
                status: .pending,
                price: 30.0,
                notes: "Morning walk",
                isPaid: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Booking(
                id: "booking2",
                ownerId: "owner1",
                walkerId: "walker1",
                petId: "pet2",
                date: Date().addingTimeInterval(172800), // Day after tomorrow
                duration: 30,
                serviceType: "Pet Sitting",
                status: .confirmed,
                price: 25.0,
                notes: "Afternoon care",
                isPaid: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        viewModel.users = [
            User(
                id: "owner1",
                email: "owner@example.com",
                phoneNumber: "+1234567890",
                userType: .owner,
                name: "John Owner",
                address: "123 Main St",
                profileImageURL: nil,
                rating: 4.5,
                numberOfRatings: 5,
                bio: nil,
                services: nil,
                hourlyRate: nil,
                documents: nil,
                availability: nil
            ),
            User(
                id: "walker1",
                email: "walker@example.com",
                phoneNumber: "+1234567891",
                userType: .walker,
                name: "Jane Walker",
                address: "456 Oak Ave",
                profileImageURL: nil,
                rating: 4.8,
                numberOfRatings: 15,
                bio: "Professional pet walker",
                services: [
                    Service(id: "1", name: "Dog Walking", description: "30-minute walks", price: 25.0),
                    Service(id: "2", name: "Pet Sitting", description: "In-home care", price: 50.0)
                ],
                hourlyRate: 30.0,
                documents: nil,
                availability: nil
            )
        ]
        viewModel.userPreferences = UserPreferences()
        return viewModel
    }
    
    /// Test adding a pet
    func testAddPet() async {
        do {
            try await addPet(
                name: "Test Pet",
                breed: "Test Breed",
                age: 2,
                notes: "Test notes",
                ownerId: "test-owner"
            )
            print("✅ Add pet test successful")
        } catch {
            print("❌ Add pet test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test creating a booking
    func testCreateBooking() async {
        do {
            try await createBooking(
                ownerId: "test-owner",
                walkerId: "test-walker",
                petId: "test-pet",
                date: Date().addingTimeInterval(86400),
                duration: 60,
                serviceType: "Test Service",
                price: 35.0,
                notes: "Test booking"
            )
            print("✅ Create booking test successful")
        } catch {
            print("❌ Create booking test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test updating booking status
    func testUpdateBookingStatus() async {
        guard let firstBooking = bookings.first else {
            print("❌ No bookings available for status update test")
            return
        }
        
        do {
            try await updateBookingStatus(bookingId: firstBooking.id, newStatus: .completed)
            print("✅ Update booking status test successful")
        } catch {
            print("❌ Update booking status test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test updating user rating
    func testUpdateUserRating() async {
        guard let firstUser = users.first else {
            print("❌ No users available for rating update test")
            return
        }
        
        do {
            try await updateUserRating(userId: firstUser.id, newRating: 5)
            print("✅ Update user rating test successful")
        } catch {
            print("❌ Update user rating test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test loading all data
    func testLoadAllData() async {
        do {
            try await loadAllData()
            print("✅ Load all data test successful")
        } catch {
            print("❌ Load all data test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test updating user preferences
    func testUpdateUserPreferences() async {
        var newPreferences = UserPreferences()
        newPreferences.notificationsEnabled = false
        newPreferences.darkModeEnabled = true
        newPreferences.languageCode = "es"
        
        do {
            try await updateUserPreferences(newPreferences)
            print("✅ Update user preferences test successful")
        } catch {
            print("❌ Update user preferences test failed: \(error.localizedDescription)")
        }
    }
}

#Preview("AppViewModel - With Data") {
    VStack(spacing: 20) {
        Text("AppViewModel Preview")
            .font(.title)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Pets Section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Pets (\(AppViewModel.preview.pets.count))")
                        .font(.headline)
                    ForEach(AppViewModel.preview.pets) { pet in
                        Text("• \(pet.name) (\(pet.breed), \(pet.age) years)")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Bookings Section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Bookings (\(AppViewModel.preview.bookings.count))")
                        .font(.headline)
                    ForEach(AppViewModel.preview.bookings) { booking in
                        Text("• \(booking.serviceType) - \(booking.status.rawValue)")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                
                // Users Section
                VStack(alignment: .leading, spacing: 5) {
                    Text("Users (\(AppViewModel.preview.users.count))")
                        .font(.headline)
                    ForEach(AppViewModel.preview.users) { user in
                        Text("• \(user.name) (\(user.userType.rawValue))")
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        
        HStack(spacing: 10) {
            Button("Test Add Pet") {
                Task {
                    await AppViewModel.preview.testAddPet()
                }
            }
            .buttonStyle(.bordered)
            
            Button("Test Create Booking") {
                Task {
                    await AppViewModel.preview.testCreateBooking()
                }
            }
            .buttonStyle(.bordered)
        }
    }
    .padding()
}

#Preview("AppViewModel - Empty") {
    VStack(spacing: 20) {
        Text("AppViewModel Preview - Empty")
            .font(.title)
        
        Text("No data loaded")
            .foregroundColor(.secondary)
        
        Button("Test Load All Data") {
            Task {
                await AppViewModel().testLoadAllData()
            }
        }
        .buttonStyle(.borderedProminent)
        
        Button("Test Update Preferences") {
            Task {
                await AppViewModel().testUpdateUserPreferences()
            }
        }
        .buttonStyle(.bordered)
    }
    .padding()
} 
