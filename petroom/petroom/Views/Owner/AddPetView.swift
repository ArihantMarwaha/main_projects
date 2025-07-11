import SwiftUI

struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var age: String = ""
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var error: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pet Info")) {
                    TextField("Name", text: $name)
                    TextField("Breed", text: $breed)
                    TextField("Age", text: $age)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes)
                }
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Pet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save", action: savePet)
                            .disabled(name.isEmpty || breed.isEmpty || age.isEmpty)
                    }
                }
            }
        }
    }
    
    private func savePet() {
        guard let owner = authViewModel.currentUser else {
            error = "User not found."
            return
        }
        guard let ageInt = Int(age), ageInt > 0 else {
            error = "Please enter a valid age."
            return
        }
        isSaving = true
        error = nil
        Task {
            do {
                _ = try await RepositoryManager.shared.createPet(
                    name: name,
                    breed: breed,
                    age: ageInt,
                    notes: notes.isEmpty ? nil : notes,
                    ownerId: owner.id
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
struct AddPetView_Previews: PreviewProvider {
    static var previews: some View {
        AddPetView()
            .environmentObject(AuthViewModel.shared)
    }
}
#endif 