import SwiftUI

struct UserManagementView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedUserType = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("User Type", selection: $selectedUserType) {
                    Text("Pet Owners").tag(0)
                    Text("Walkers").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                List {
                    if selectedUserType == 0 {
                        // TODO: Replace with actual pet owners
                        Text("No pet owners found")
                            .foregroundColor(.gray)
                    } else {
                        // TODO: Replace with actual walkers
                        Text("No walkers found")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("User Management")
        }
    }
} 