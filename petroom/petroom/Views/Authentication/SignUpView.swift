import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var address = ""
    @State private var userType: UserType = .owner
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "pawprint.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                
                Picker("I am a", selection: $userType) {
                    Text("Pet Owner").tag(UserType.owner)
                    Text("Walker/Trainer").tag(UserType.walker)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Full Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.name)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.newPassword)
                
                TextField("Address", text: $address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.fullStreetAddress)
                
                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Button(action: {
                        // Validate passwords match
                        guard password == confirmPassword else {
                            authViewModel.error = "Passwords do not match"
                            return
                        }
                        Task {
                            do {
                                try await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    name: name, userType: userType
                                )
                            } catch {
                                authViewModel.error = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                
                if let error = authViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
    }
} 

