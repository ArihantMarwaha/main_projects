import SwiftUI

struct ContentView: View {
    @StateObject private var goalsManager = GoalsManager()
    
    var body: some View {
        MainTabView()
            .environmentObject(goalsManager)
            .onAppear {
                goalsManager.startObservingAppState()
            }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




