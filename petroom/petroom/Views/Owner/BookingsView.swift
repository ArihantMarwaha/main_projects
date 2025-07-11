import SwiftUI

struct BookingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var bookings: [Booking] = []
    @State private var pets: [Pet] = []
    @State private var users: [User] = []
    @State private var isLoading = true
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Booking Status", selection: $selectedTab) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if isLoading {
                    ProgressView().padding()
                } else if let error = error {
                    Text(error).foregroundColor(.red).padding()
                } else {
                    if selectedTab == 0 {
                        UpcomingBookingsView(bookings: upcomingBookings, pets: pets, users: users)
                    } else {
                        PastBookingsView(bookings: pastBookings, pets: pets, users: users)
                    }
                }
            }
            .navigationTitle("Bookings")
            .onAppear(perform: loadData)
        }
    }
    
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
                try await RepositoryManager.shared.insertDemoWalkersIfNeeded()
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
    
    private var upcomingBookings: [Booking] {
        let now = Date()
        return bookings.filter { $0.date > now && ($0.status == .pending || $0.status == .confirmed || $0.status == .inProgress) }
            .sorted { $0.date < $1.date }
    }
    private var pastBookings: [Booking] {
        return bookings.filter { $0.status == .completed || $0.status == .cancelled }
            .sorted { $0.date > $1.date }
    }
}

struct UpcomingBookingsView: View {
    let bookings: [Booking]
    let pets: [Pet]
    let users: [User]
    var body: some View {
        List {
            if bookings.isEmpty {
                Text("No upcoming bookings")
                    .foregroundColor(.gray)
            } else {
                ForEach(bookings, id: \ .id) { booking in
                    BookingCardView(
                        booking: booking,
                        pet: pets.first(where: { $0.id == booking.petId }),
                        walker: users.first(where: { $0.id == booking.walkerId })
                    )
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

struct PastBookingsView: View {
    let bookings: [Booking]
    let pets: [Pet]
    let users: [User]
    var body: some View {
        List {
            if bookings.isEmpty {
                Text("No past bookings")
                    .foregroundColor(.gray)
            } else {
                ForEach(bookings, id: \ .id) { booking in
                    BookingCardView(
                        booking: booking,
                        pet: pets.first(where: { $0.id == booking.petId }),
                        walker: users.first(where: { $0.id == booking.walkerId })
                    )
                    .padding(.vertical, 4)
                }
            }
        }
    }
} 