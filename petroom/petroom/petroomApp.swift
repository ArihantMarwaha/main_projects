//
//  petroomApp.swift
//  petroom
//
//  Created by Arihant Marwaha on 12/06/25.
//

import SwiftUI
import SwiftData
import Combine

/// Main entry point of the application
/// Sets up the root view and initializes the app
@main
struct petroomApp: App {
    var body: some Scene {
        WindowGroup {
            // ContentView is the root view that manages authentication and main navigation
            ContentView()
                .modelContainer(for: [UserModel.self])
        }
    }
}

/*
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
                
                EarningsView()
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
*/
