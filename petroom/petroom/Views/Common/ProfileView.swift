import SwiftUI
import PhotosUI

/// View for displaying and managing user profile information
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileUIImage: UIImage? = nil
    
    // Demo user data; replace with your actual user model/binding
    let name: String = "Arihant Marwaha"
    let email: String = "ari@example.com"
    let phone: String = "+1 234 567 8901"
    let address: String = "123 Main Street, Springfield"
    let memberSince: String = "Jan 2023"
    let profileImage: Image = Image(systemName: "person.crop.circle.fill")

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Profile Image Card with tap to change
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.25), Color.green.opacity(0.25)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
                        Group {
                            if let uiImage = profileUIImage {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .onTapGesture {
                            showingImagePicker = true
                        }
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                        .padding(6)
                                }
                            }
                        )
                    }
                    .padding(.top, 40)

                    // Info Card
                    VStack(alignment: .leading, spacing: 24) {
                        ProfileRow(label: "Name", value: name, large: true)
                        Divider()
                        ProfileRow(label: "Email", value: email)
                        Divider()
                        ProfileRow(label: "Phone", value: phone)
                        Divider()
                        ProfileRow(label: "Address", value: address)
                        Divider()
                        ProfileRow(label: "Member Since", value: memberSince)
                    }
                    .padding(28)
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
                    )
                    .padding(.horizontal, 0) // Edges complete

                    // Sign Out Button
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                                .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, -18)

                    Spacer()
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Text("Edit")
                    }
                    .accessibilityLabel("Edit Profile")
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView()
            }
        }
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { newItem in
            if let newItem {
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileUIImage = uiImage
                    }
                }
            }
        }
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    var large: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(large ? .system(size: 28, weight: .bold, design: .rounded) : .title3)
                .foregroundColor(.primary)
                .lineLimit(2)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}


