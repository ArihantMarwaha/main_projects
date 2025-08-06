//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct ProgressRingView: View {
    let tracker: GoalTracker  // Changed from @ObservedObject to let
    let ringWidth: CGFloat
    @State private var currentProgress: Double  // Add state to manage animations
    
    init(tracker: GoalTracker, ringWidth: CGFloat) {
        self.tracker = tracker
        self.ringWidth = ringWidth
        self._currentProgress = State(initialValue: tracker.getProgress())
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: ringWidth)
            
            Circle()
                .trim(from: 0, to: currentProgress)
                .stroke(tracker.goal.colorScheme.gradient, style: StrokeStyle(
                    lineWidth: ringWidth,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(currentProgress * 100))%")
                    .font(.title)
                    .bold()
                    .contentTransition(.numericText())
                
                Text("\(Int(currentProgress * Double(tracker.goal.targetCount)))/\(tracker.goal.targetCount)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .contentTransition(.numericText())
            }
        }
        .padding()
        .onAppear {
            updateProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            updateProgress()
        }
    }
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
            currentProgress = tracker.getProgress()
        }
    }
}


//preview function
/*

 struct ProgressRingView_Preview: View {
     var body: some View {
         ProgressRingView(
             tracker: GoalTracker(
                 goal: Goal(
                     title: "Take Breaks",
                     targetCount: 5,
                     intervalInSeconds: 2 * 3600, // 2 hours
                     colorScheme: .green,
                     startTime: Calendar.current.startOfDay(for: Date())
                 )
             ),
             ringWidth: 20
         )
         .frame(width: 200, height: 200) // Adjust size for preview
     }
 }

 #Preview {
     ProgressRingView_Preview()
 }


*/


