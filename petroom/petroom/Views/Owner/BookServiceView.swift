import SwiftUI

struct BookServiceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedPetId: String = ""
    @State private var serviceType: String = "Dog Walking"
    @State private var date = Date()
    @State private var duration: String = "60"
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var error: String?
    @State private var pets: [Pet] = []
    @State private var selectedWalkerId: String = ""
    @State private var walkers: [User] = []
    
    let serviceTypes = ["Dog Walking", "Pet Sitting", "Training"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet")) {
                    if pets.isEmpty {
                        Text("No pets found. Please add a pet first.")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Pet", selection: $selectedPetId) {
                            ForEach(pets) { pet in
                                Text(pet.name).tag(pet.id)
                            }
                        }
                    }
                }
                Section(header: Text("Walker")) {
                    if walkers.isEmpty {
                        Text("No walkers available.")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Select Walker", selection: $selectedWalkerId) {
                            ForEach(walkers) { walker in
                                Text(walker.name).tag(walker.id)
                            }
                        }
                    }
                }
                Section(header: Text("Service Details")) {
                    Picker("Service Type", selection: $serviceType) {
                        ForEach(serviceTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    DatePicker("Date & Time", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                    TextField("Duration (minutes)", text: $duration)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes)
                }
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Book Service")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Book", action: saveBooking)
                            .disabled(selectedPetId.isEmpty || selectedWalkerId.isEmpty || duration.isEmpty)
                    }
                }
            }
            .onAppear(perform: loadData)
        }
    }
    
    private func loadData() {
        guard let user = authViewModel.currentUser else { return }
        Task {
            do {
                let pets = try await RepositoryManager.shared.getPetsForOwner(user.id)
                self.pets = pets
                if let first = pets.first { self.selectedPetId = first.id }
                let allUsers = try await RepositoryManager.shared.getAllUsers()
                let walkers = allUsers.filter { $0.userType == .walker }
                self.walkers = walkers
                if let first = walkers.first { self.selectedWalkerId = first.id }
            } catch {
                self.pets = []
                self.walkers = []
            }
        }
    }
    
    private func saveBooking() {
        guard let owner = authViewModel.currentUser else {
            error = "User not found."
            return
        }
        guard let durationInt = Int(duration), durationInt > 0 else {
            error = "Please enter a valid duration."
            return
        }
        guard !selectedPetId.isEmpty else {
            error = "Please select a pet."
            return
        }
        guard !selectedWalkerId.isEmpty else {
            error = "Please select a walker."
            return
        }
        isSaving = true
        error = nil
        Task {
            do {
                _ = try await RepositoryManager.shared.createBooking(
                    ownerId: owner.id,
                    walkerId: selectedWalkerId,
                    petId: selectedPetId,
                    date: date,
                    duration: durationInt,
                    serviceType: serviceType,
                    price: 25.0, // For demo, fixed price
                    notes: notes.isEmpty ? nil : notes
                )
                isSaving = false
                dismiss()
            } catch {
                self.error = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#if DEBUG
struct BookServiceView_Previews: PreviewProvider {
    static var previews: some View {
        BookServiceView()
            .environmentObject(AuthViewModel.shared)
    }
}
#endif 