//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct WaterTrackerView: View {
    @StateObject var tracker: WaterGoalTracker
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        GoalTrackerView(tracker: tracker)
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    // Refresh data when app becomes active
                    tracker.loadSavedData()
                }
            }
    }
}

struct WaterTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = GoalsManager()
        let waterGoal = Goal(
            title: "Water Intake",
            targetCount: 8,
            intervalInSeconds: 3600,
            colorScheme: .blue,
            isDefault: true
        )
        
        // Create the tracker using the manager's analyticsManager
        let tracker = WaterGoalTracker(
            goal: waterGoal,
            analyticsManager: previewManager.analyticsManager
        )
        
        return NavigationView {
            WaterTrackerView(tracker: tracker)
                .environmentObject(previewManager)
        }
    }
}


