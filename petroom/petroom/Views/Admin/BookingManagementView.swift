import SwiftUI

struct BookingManagementView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedStatus = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Booking Status", selection: $selectedStatus) {
                    Text("Active").tag(0)
                    Text("Pending").tag(1)
                    Text("Completed").tag(2)
                    Text("Cancelled").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    // TODO: Replace with actual bookings
                    Text("No bookings found")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Booking Management")
        }
    }
} 