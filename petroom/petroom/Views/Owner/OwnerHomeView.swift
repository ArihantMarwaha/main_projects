import SwiftUI

struct OwnerHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddPet = false
    @State private var showingBookService = false
    @State private var showHistory = false
    
    @State private var bookings: [Booking] = []
    @State private var pets: [Pet] = []
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            QuickActionButton(
                                title: "Book Service",
                                systemImage: "calendar.badge.plus",
                                action: { showingBookService = true }
                            )
                            
                            QuickActionButton(
                                title: "Add Pet",
                                systemImage: "pawprint.circle.fill",
                                action: { showingAddPet = true }
                            )
                            
                            QuickActionButton(
                                title: "View History",
                                systemImage: "clock.fill",
                                action: { showHistory = true }
                            )
                        }
                        .padding(.horizontal)
                        Button("Insert Demo Bookings") {
                            insertDemoBookings()
                        }
                        .font(.caption)
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Bookings
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upcoming Bookings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            let upcoming = upcomingBookings
                            if upcoming.isEmpty {
                                Text("No upcoming bookings")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(upcoming, id: \ .booking.id) { item in
                                    BookingCardView(booking: item.booking, pet: item.pet, walker: item.walker)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    // Recent Activity
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if let error = error {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            let activity = recentActivity
                            if activity.isEmpty {
                                Text("No recent activity")
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                ForEach(activity, id: \ .booking.id) { item in
                                    ActivityCardView(booking: item.booking, pet: item.pet, walker: item.walker)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingBookService) {
                BookServiceView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showHistory) {
                BookingHistoryView(bookings: bookings, pets: pets, users: users)
            }
            .onAppear(perform: loadData)
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        isLoading = true
        error = nil
        Task {
            guard let user = authViewModel.currentUser else {
                error = "User not found."
                isLoading = false
                return
            }
            do {
                let repo = RepositoryManager.shared
                async let bookingsResult = repo.getBookingsForUser(user.id, userType: .owner)
                async let petsResult = repo.getAllPets()
                async let usersResult = repo.getAllUsers()
                self.bookings = try await bookingsResult
                self.pets = try await petsResult
                self.users = try await usersResult
                isLoading = false
            } catch {
                self.error = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    // MARK: - Helpers
    private var upcomingBookings: [(booking: Booking, pet: Pet?, walker: User?)] {
        let now = Date()
        return bookings
            .filter { $0.date > now && ($0.status == .pending || $0.status == .confirmed || $0.status == .inProgress) }
            .sorted { $0.date < $1.date }
            .map { booking in
                (
                    booking: booking,
                    pet: pets.first(where: { $0.id == booking.petId }),
                    walker: users.first(where: { $0.id == booking.walkerId })
                )
            }
    }
    private var recentActivity: [(booking: Booking, pet: Pet?, walker: User?)] {
        return bookings
            .filter { $0.status == .completed || $0.status == .cancelled }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
            .map { booking in
                (
                    booking: booking,
                    pet: pets.first(where: { $0.id == booking.petId }),
                    walker: users.first(where: { $0.id == booking.walkerId })
                )
            }
    }
    
    private func insertDemoBookings() {
        guard let user = authViewModel.currentUser else { return }
        Task {
            do {
                try await RepositoryManager.shared.insertDemoWalkersIfNeeded()
                let allUsers = try await RepositoryManager.shared.getAllUsers()
                let walkers = allUsers.filter { $0.userType == .walker }
                try await RepositoryManager.shared.insertDemoBookings(for: user, pets: pets, walkers: walkers)
                loadData()
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
} 
