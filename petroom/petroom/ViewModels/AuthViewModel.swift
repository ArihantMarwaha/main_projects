import Foundation
import SwiftUI
import Combine
import SwiftData

/// View model for handling authentication and user management
class AuthViewModel: ObservableObject {
    /// Shared instance for app-wide access
    static let shared = AuthViewModel()
    
    /// Published properties for reactive UI updates
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // Repository manager for data operations
    private let repositoryManager = RepositoryManager.shared
    
    init() {}
    
    /// Set the model context (call this from ContentView or App)
    func setModelContext(_ context: ModelContext) {
        repositoryManager.setModelContext(context)
    }
    
    /// Signs in a user with email
    @MainActor
    func signIn(email: String, password: String = "") async throws {
        print("🔧 AuthViewModel: Starting sign in for email: \(email)")
        isLoading = true
        error = nil
        
        do {
            let user = try await repositoryManager.signInUser(email: email, password: password)
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            print("✅ AuthViewModel: Sign in successful for user: \(user.name)")
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
            print("❌ AuthViewModel: Sign in failed: \(error.localizedDescription)")
        }
    }
    
    /// Signs up a new user
    @MainActor
    func signUp(email: String, password: String, name: String, userType: UserType) async throws {
        print("🔧 AuthViewModel: Starting sign up for email: \(email)")
        isLoading = true
        error = nil
        
        do {
            let user = try await repositoryManager.createUser(email: email, name: name, userType: userType)
            await repositoryManager.setCurrentUser(user)
            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false
            print("✅ AuthViewModel: Sign up successful for user: \(user.name)")
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
            print("❌ AuthViewModel: Sign up failed: \(error.localizedDescription)")
        }
    }
    
    /// Signs out the current user
    @MainActor
    func signOut() {
        Task {
            await repositoryManager.clearCurrentUser()
        }
        currentUser = nil
        isAuthenticated = false
    }
    
    /// Updates the user's profile information
    @MainActor
    func updateProfile(_ user: User?) async throws {
        guard let user = user else {
            throw NSError(domain: "AuthViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        isLoading = true
        error = nil
        
        do {
            try await repositoryManager.updateUser(user)
            self.currentUser = user
            self.isLoading = false
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
    
    /// Uploads a profile image and updates the user's profile
    func uploadProfileImage(_ imageData: Data) async throws -> String {
        // TODO: Implement actual image upload
        // This is a placeholder implementation that returns a mock URL
        return "https://example.com/profile/\(UUID().uuidString).jpg"
    }
    
    /// Try to restore session from stored user ID
    @MainActor
    func restoreSession() async {
        do {
            if let user = try await repositoryManager.restoreSession() {
                self.currentUser = user
                self.isAuthenticated = true
            }
        } catch {
            // Session restoration failed, user needs to log in again
            print("Session restoration failed: \(error.localizedDescription)")
        }
    }
    
    /// Test sign out
    func testSignOut() {
        signOut()
        print("✅ Sign out test successful")
    }
    
    /// Test complete user lifecycle (sign up, sign out, sign in)
    func testUserLifecycle() async {
        print("🔄 Starting user lifecycle test...")
        
        // Debug: List all users before test
        await repositoryManager.debugListAllUsers()
        
        // Step 1: Sign up a new user
        do {
            try await signUp(
                email: "lifecycle@example.com",
                password: "password123",
                name: "Lifecycle Test User",
                userType: .owner
            )
            print("✅ Step 1: Sign up successful")
            
            // Verify user is authenticated
            guard isAuthenticated, let user = currentUser else {
                print("❌ Step 1: User not properly authenticated after sign up")
                return
            }
            print("✅ Step 1: User authenticated - ID: \(user.id), Email: \(user.email)")
            
            // Debug: List all users after sign up
            await repositoryManager.debugListAllUsers()
            
        } catch {
            print("❌ Step 1: Sign up failed: \(error.localizedDescription)")
            return
        }
        
        // Step 2: Sign out
        signOut()
        print("✅ Step 2: Sign out successful")
        
        // Verify user is not authenticated
        guard !isAuthenticated, currentUser == nil else {
            print("❌ Step 2: User still authenticated after sign out")
            return
        }
        print("✅ Step 2: User properly signed out")
        
        // Debug: List all users after sign out
        await repositoryManager.debugListAllUsers()
        
        // Step 3: Sign in with the same email
        do {
            try await signIn(email: "lifecycle@example.com", password: "password123")
            print("✅ Step 3: Sign in successful")
            
            // Verify user is authenticated again
            guard isAuthenticated, let user = currentUser else {
                print("❌ Step 3: User not properly authenticated after sign in")
                return
            }
            print("✅ Step 3: User re-authenticated - ID: \(user.id), Email: \(user.email)")
            
        } catch {
            print("❌ Step 3: Sign in failed: \(error.localizedDescription)")
            return
        }
        
        print("🎉 User lifecycle test completed successfully!")
    }
    
    /// Debug method to list all users
    func debugListAllUsers() async {
        await repositoryManager.debugListAllUsers()
    }
}

extension UserModel {
    func toUser() -> User {
        User(
            id: self.id,
            email: self.email,
            phoneNumber: self.phoneNumber,
            userType: UserType(rawValue: self.userType) ?? .owner,
            name: self.name,
            address: self.address,
            profileImageURL: self.profileImageURL,
            rating: self.rating,
            numberOfRatings: self.numberOfRatings,
            bio: self.bio,
            services: nil,
            hourlyRate: self.hourlyRate,
            documents: nil,
            availability: nil
        )
    }
}

// MARK: - Preview Support

extension AuthViewModel {
    /// Preview instance with mock data for testing
    static var preview: AuthViewModel {
        let viewModel = AuthViewModel()
        viewModel.currentUser = User(
            id: "preview-user-id",
            email: "test@example.com",
            phoneNumber: "+1234567890",
            userType: .owner,
            name: "John Doe",
            address: "123 Main St",
            profileImageURL: nil,
            rating: 4.5,
            numberOfRatings: 10,
            bio: "Pet lover and owner",
            services: nil,
            hourlyRate: nil,
            documents: nil,
            availability: nil
        )
        viewModel.isAuthenticated = true
        return viewModel
    }
    
    /// Preview instance for walker
    static var previewWalker: AuthViewModel {
        let viewModel = AuthViewModel()
        viewModel.currentUser = User(
            id: "preview-walker-id",
            email: "walker@example.com",
            phoneNumber: "+1234567890",
            userType: .walker,
            name: "Jane Walker",
            address: "456 Oak Ave",
            profileImageURL: nil,
            rating: 4.8,
            numberOfRatings: 25,
            bio: "Professional pet walker with 5 years experience",
            services: [
                Service(id: "1", name: "Dog Walking", description: "30-minute walks", price: 25.0),
                Service(id: "2", name: "Pet Sitting", description: "In-home pet care", price: 50.0)
            ],
            hourlyRate: 30.0,
            documents: nil,
            availability: nil
        )
        viewModel.isAuthenticated = true
        return viewModel
    }
    
    /// Preview instance for unauthenticated state
    static var previewUnauthenticated: AuthViewModel {
        let viewModel = AuthViewModel()
        viewModel.currentUser = nil
        viewModel.isAuthenticated = false
        return viewModel
    }
    
    /// Test sign up functionality
    func testSignUp() async {
        do {
            try await signUp(
                email: "test@example.com",
                password: "password123",
                name: "Test User",
                userType: .owner
            )
            print("✅ Sign up test successful")
        } catch {
            print("❌ Sign up test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test sign in functionality
    func testSignIn() async {
        do {
            try await signIn(email: "test@example.com", password: "password123")
            print("✅ Sign in test successful")
        } catch {
            print("❌ Sign in test failed: \(error.localizedDescription)")
        }
    }
    
    /// Test profile update
    func testProfileUpdate() async {
        guard let currentUser = currentUser else {
            print("❌ No current user for profile update test")
            return
        }
        
        var updatedUser = currentUser
        updatedUser.name = "Updated Name"
        updatedUser.bio = "Updated bio"
        
        do {
            try await updateProfile(updatedUser)
            print("✅ Profile update test successful")
        } catch {
            print("❌ Profile update test failed: \(error.localizedDescription)")
        }
    }
}

#Preview("AuthViewModel - Owner") {
    VStack(spacing: 20) {
        Text("AuthViewModel Preview - Owner")
            .font(.title)
        
        if let user = AuthViewModel.preview.currentUser {
            VStack(alignment: .leading, spacing: 10) {
                Text("User: \(user.name)")
                Text("Email: \(user.email)")
                Text("Type: \(user.userType.rawValue)")
                Text("Rating: \(user.averageRating, specifier: "%.1f")")
                if let bio = user.bio {
                    Text("Bio: \(bio)")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        
        Button("Test Sign Out") {
            AuthViewModel.preview.testSignOut()
        }
        .buttonStyle(.borderedProminent)
    }
    .padding()
}

#Preview("AuthViewModel - Walker") {
    VStack(spacing: 20) {
        Text("AuthViewModel Preview - Walker")
            .font(.title)
        
        if let user = AuthViewModel.previewWalker.currentUser {
            VStack(alignment: .leading, spacing: 10) {
                Text("User: \(user.name)")
                Text("Email: \(user.email)")
                Text("Type: \(user.userType.rawValue)")
                Text("Rating: \(user.averageRating, specifier: "%.1f")")
                if let bio = user.bio {
                    Text("Bio: \(bio)")
                }
                if let hourlyRate = user.hourlyRate {
                    Text("Hourly Rate: $\(hourlyRate, specifier: "%.2f")")
                }
                if let services = user.services {
                    Text("Services: \(services.count)")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
    }
    .padding()
}

#Preview("AuthViewModel - Unauthenticated") {
    VStack(spacing: 20) {
        Text("AuthViewModel Preview - Unauthenticated")
            .font(.title)
        
        Text("Not logged in")
            .foregroundColor(.secondary)
        
        Button("Test Sign Up") {
            Task {
                await AuthViewModel.previewUnauthenticated.testSignUp()
            }
        }
        .buttonStyle(.borderedProminent)
        
        Button("Test Sign In") {
            Task {
                await AuthViewModel.previewUnauthenticated.testSignIn()
            }
        }
        .buttonStyle(.bordered)
    }
    .padding()
}

#Preview("AuthViewModel - User Lifecycle Test") {
    VStack(spacing: 20) {
        Text("User Lifecycle Test")
            .font(.title)
        
        Text("Test complete user flow: Sign Up → Sign Out → Sign In")
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        
        Button("Run Lifecycle Test") {
            Task {
                await AuthViewModel.previewUnauthenticated.testUserLifecycle()
            }
        }
        .buttonStyle(.borderedProminent)
        
        Button("Debug: List All Users") {
            Task {
                await AuthViewModel.previewUnauthenticated.debugListAllUsers()
            }
        }
        .buttonStyle(.bordered)
        
        Text("Check console for detailed test results")
            .font(.caption2)
            .foregroundColor(.secondary)
    }
    .padding()
} 
