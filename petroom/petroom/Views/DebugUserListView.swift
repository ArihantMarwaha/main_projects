import SwiftUI

struct DebugUserListView: View {
    @ObservedObject var repositoryManager = RepositoryManager.shared
    @State private var isExported = false
    
    var body: some View {
        NavigationView {
            VStack {
                if repositoryManager.debugAllUsers.isEmpty {
                    Text("No users found.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List(repositoryManager.debugAllUsers, id: \ .id) { user in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name).font(.headline)
                            Text("Email: \(user.email)").font(.caption)
                            Text("ID: \(user.id)").font(.caption2).foregroundColor(.gray)
                            Text("Type: \(user.userType.rawValue)").font(.caption2)
                        }
                        .padding(.vertical, 4)
                    }
                }
                HStack {
                    Button("Refresh List") {
                        Task { await repositoryManager.loadAllUsersForDebug() }
                    }
                    .buttonStyle(.borderedProminent)
                    Button("Export to File") {
                        Task {
                            await repositoryManager.exportAllUsersToFile()
                            isExported = true
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.top)
                if isExported {
                    Text("Exported to users_export.json in app's documents directory.")
                        .font(.caption2)
                        .foregroundColor(.green)
                        .padding(.top, 4)
                }
            }
            .navigationTitle("All Users (Debug)")
            .onAppear {
                Task { await repositoryManager.loadAllUsersForDebug() }
            }
        }
    }
}

#Preview {
    DebugUserListView()
} 