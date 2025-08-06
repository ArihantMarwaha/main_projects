//
//  SwiftDataMigration.swift
//  GUGUios
//
//  SwiftData migration utilities for handling schema changes
//

import Foundation
import SwiftData

struct SwiftDataMigration {
    
    /// Clears all SwiftData stores to handle schema changes during development
    static func clearAllData() {
        let urls = [
            getDocumentsDirectory().appendingPathComponent("default.store"),
            getDocumentsDirectory().appendingPathComponent("default.store-shm"),
            getDocumentsDirectory().appendingPathComponent("default.store-wal")
        ]
        
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
        
        print("🗑️ Cleared SwiftData stores for schema migration")
    }
    
    /// Gets the documents directory for the app
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    /// Creates a fresh ModelContainer with error handling for schema changes
    static func createModelContainer() -> ModelContainer {
        let schema = Schema([
            SDGoal.self,
            SDGoalEntry.self,
            SDJournalEntry.self,
            SDAnalytics.self,
            SDPetData.self,
            SDGoalStreak.self
        ])
        
        // First attempt: Normal configuration with memory safety settings
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ Successfully created ModelContainer with existing data")
            return container
        } catch {
            print("⚠️ Schema migration needed: \(error)")
            
            // Clear existing data and try again
            clearAllData()
            
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ Successfully created ModelContainer after clearing data")
                return container
            } catch {
                print("❌ Failed to create ModelContainer even after clearing data: \(error)")
                
                // Fallback to in-memory storage
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                
                do {
                    let container = try ModelContainer(for: schema, configurations: [memoryConfiguration])
                    print("⚠️ Using in-memory storage as fallback")
                    return container
                } catch {
                    fatalError("Could not create ModelContainer even in memory: \(error)")
                }
            }
        }
    }
}