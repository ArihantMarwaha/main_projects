//
//  GUGUiosApp.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI
import SwiftData
import AppIntents
import UserNotifications

@main
struct GUGUiosApp: App {
    static var appShortcutsProvider: any AppShortcutsProvider.Type {
        GUGUiosAppShortcuts.self
    }
    // SwiftData model container with migration handling
    var sharedModelContainer: ModelContainer = SwiftDataMigration.createModelContainer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // goalsManager.startObservingAppState() will be called in ContentView
                    Task {
                        await requestNotificationPermissions()
                    }
                    
                    // Configure App Intents and App Shortcuts
                    AppIntentsManager.configureAppIntents()
                    AppIntentsDonationHelper.shared.donateCommonIntents()
                    
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func requestNotificationPermissions() async {
        // Set up notification delegate first
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        let granted = await NotificationManager.shared.requestPermission()
        if granted {
            print("✅ Notification permissions granted")
            
            // Register notification categories
            NotificationDelegate.shared.registerNotificationCategories()
        } else {
            print("❌ Notification permissions denied")
        }
    }
    
    
}


/*@main
 struct GUGUiosApp: App {
     var body: some Scene {
         WindowGroup {
             ContentView()
         }
     }
 }
 */
