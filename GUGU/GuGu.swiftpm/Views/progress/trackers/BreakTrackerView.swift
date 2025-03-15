//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct BreakTrackerView: View {
    @StateObject var tracker: BreakGoalTracker
    @State private var isBreakActive = false
    
    var body: some View {
        VStack {
            GoalTrackerView(tracker: tracker)
            
            if isBreakActive {
                BreakTimerView(duration: 300) { // 5-minute break
                    isBreakActive = false
                }
            }
        }
    }
}

struct BreakTimerView: View {
    let duration: TimeInterval
    let onComplete: () -> Void
    
    @State private var timeRemaining: TimeInterval
    @State private var isActive = true
    
    init(duration: TimeInterval, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        _timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        VStack {
            Text(timeString(from: timeRemaining))
                .font(.title)
                .bold()
                .padding()
            
            Button(isActive ? "Pause" : "Resume") {
                isActive.toggle()
            }
            .padding()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                onComplete()
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Preview
struct BreakTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = GoalsManager()
        let breakGoal = Goal(
            title: "Take Breaks",
            targetCount: 6,
            intervalInSeconds: 7200,
            colorScheme: .green,
            isDefault: true
        )
        
        // Create the tracker using the manager's analyticsManager
        let tracker = BreakGoalTracker(
            goal: breakGoal,
            analyticsManager: previewManager.analyticsManager
        )
        
        return NavigationView {
            BreakTrackerView(tracker: tracker)
                .environmentObject(previewManager)
        }
    }
}
