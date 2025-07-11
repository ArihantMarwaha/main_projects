import SwiftUI
import PhotosUI

/// View for editing user profile information
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // Form fields
    @State private var name: String
    @State private var email: String
    @State private var phoneNumber: String
    @State private var address: String
    @State private var bio: String
    @State private var hourlyRate: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileImage: Image?
    @State private var imageData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init() {
        let user = AuthViewModel.shared.currentUser
        _name = State(initialValue: user?.name ?? "")
        _email = State(initialValue: user?.email ?? "")
        _phoneNumber = State(initialValue: user?.phoneNumber ?? "")
        _address = State(initialValue: user?.address ?? "")
        _bio = State(initialValue: user?.bio ?? "")
        _hourlyRate = State(initialValue: user?.hourlyRate.map { String(format: "%.2f", $0) } ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Card
                VStack(alignment: .leading, spacing: 18) {
                    Text("Edit Profile")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 4)
                        .foregroundColor(.primary)

                    // Name Field
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        TextField("Name", text: $name)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .font(.body)
                    }
                    .frame(height: 44)

                    // Email Field
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .font(.body)
                    }
                    .frame(height: 44)

                    // Phone Field
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        TextField("Phone", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .font(.body)
                    }
                    .frame(height: 44)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
                )
                .padding(.horizontal)

                // Save Button
                Button(action: {
                    Task {
                        await saveProfile()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                Spacer()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        imageData = data
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    /// Saves the updated profile information
    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !name.isEmpty else {
            errorMessage = "Name cannot be empty"
            isLoading = false
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Email cannot be empty"
            isLoading = false
            return
        }
        
        do {
            // Create updated user
            var updatedUser = authViewModel.currentUser
            updatedUser?.name = name
            updatedUser?.email = email
            updatedUser?.phoneNumber = phoneNumber
            updatedUser?.address = address
            
            if authViewModel.currentUser?.userType == .walker {
                updatedUser?.bio = bio
                if let rate = Double(hourlyRate) {
                    updatedUser?.hourlyRate = rate
                }
            }
            
            // Upload profile image if changed
            if let imageData = imageData {
                let imageURL = try await authViewModel.uploadProfileImage(imageData)
                updatedUser?.profileImageURL = imageURL
            }
            
            // Update user profile
            try await authViewModel.updateProfile(updatedUser)
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

 
