//
//  GUGUiosApp.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI



@main
struct GUGUiosApp: App {
    @StateObject private var goalsManager = GoalsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(goalsManager)
                .onAppear {
                    goalsManager.startObservingAppState()
                }
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
