//
//  ContentView.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var goalsManager: GoalsManager?
    
    var body: some View {
        Group {
            if let goalsManager = goalsManager {
                MainTabView()
                    .environmentObject(goalsManager)
                    .environmentObject(AppearanceManager.shared)
            } else {
                ProgressView("Loading...")
            }
        }
        .applyAppearanceSettings()
        .onAppear {
            if goalsManager == nil {
                goalsManager = GoalsManager(modelContext: modelContext)
                goalsManager?.startObservingAppState()
                
                // Setup App Intents Manager after goals are loaded
                Task { @MainActor in
                    if let goalsManager = goalsManager {
                        AppIntentsManager.shared.setup(
                            goalsManager: goalsManager,
                            petActivityManager: goalsManager.petActivityManager
                        )
                        print("✅ App Intents Manager setup completed")
                        
                    }
                }
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

