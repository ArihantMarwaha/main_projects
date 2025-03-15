import SwiftUI

@main
struct MyApp: App {
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




