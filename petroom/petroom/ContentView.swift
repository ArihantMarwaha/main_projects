//
//  ContentView.swift
//  petroom
//
//  Created by Arihant Marwaha on 12/06/25.
//

import SwiftUI
import SwiftData

/// Root view of the application
/// Manages authentication state and main navigation structure
struct ContentView: View {
    /// View model for handling authentication state and user management
    @StateObject private var authViewModel = AuthViewModel()
    
    /// View model for handling app-wide data and state
    @StateObject private var appViewModel = AppViewModel()
    
    @Environment(\.modelContext) private var modelContext 
    
    @State private var showDebugUserList = false
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // Show main app interface for authenticated users
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(appViewModel)
            } else {
                // Show authentication interface for unauthenticated users
                AuthenticationView()
                    .environmentObject(authViewModel)
                    .environmentObject(appViewModel)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Debug Users") {
                    showDebugUserList = true
                }
            }
        }
        .sheet(isPresented: $showDebugUserList) {
            DebugUserListView()
        }
        .onAppear {
            print("🔧 ContentView: onAppear called")
            print("🔧 ContentView: ModelContext available: \(modelContext != nil)")
            
            authViewModel.setModelContext(modelContext)
            appViewModel.setModelContext(modelContext)
            
            Task {
                // Ensure default profiles exist for testing
                await RepositoryManager.shared.createDefaultProfilesIfNeeded()
                print("🔧 ContentView: Starting session restoration")
                await authViewModel.restoreSession()
                if authViewModel.isAuthenticated {
                    print("🔧 ContentView: User authenticated, loading app data")
                    try? await appViewModel.loadAllData()
                } else {
                    print("🔧 ContentView: No authenticated user found")
                }
            }
        }
    }
}

/// Main tab-based navigation view for authenticated users
/// Shows different tabs based on user type (owner, walker, or admin)
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        TabView {
            if authViewModel.currentUser?.userType == .owner {
                // Pet Owner Tabs
                OwnerHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                BookingsView()
                    .tabItem {
                        Label("Bookings", systemImage: "calendar")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            } else if authViewModel.currentUser?.userType == .walker {
                // Walker Tabs
                WalkerHomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                ScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                
                EarningsView(viewModel: EarningsViewModel())
                    .tabItem {
                        Label("Earnings", systemImage: "dollarsign.circle")
                    }
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            } else if authViewModel.currentUser?.userType == .admin {
                // Admin Tabs
                AdminDashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar")
                    }
                
                UserManagementView()
                    .tabItem {
                        Label("Users", systemImage: "person.2")
                    }
                
                BookingManagementView()
                    .tabItem {
                        Label("Bookings", systemImage: "calendar")
                    }
            }
        }
    }
}

/// Authentication view that handles sign in and sign up flows
struct AuthenticationView: View {
    /// State to toggle between sign in and sign up views
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isSignUp {
                    // Show sign up form
                    SignUpView()
                } else {
                    // Show sign in form
                    SignInView()
                }
                
                // Toggle button between sign in and sign up
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationTitle(isSignUp ? "Sign Up" : "Sign In")
        }
    }
}

#Preview {
    ContentView()
}


