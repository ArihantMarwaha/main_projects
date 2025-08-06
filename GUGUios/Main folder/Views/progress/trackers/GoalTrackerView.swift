//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import Combine


//goal tracker view that implements the goals in the bigger screen

 struct GoalTrackerView: View {
     @ObservedObject var tracker: GoalTracker
     @State private var progress: Double = 0
     
     var body: some View {
         VStack {
             Text(tracker.goal.title)
                 .font(.headline)
             
             ProgressRingView(tracker: tracker, ringWidth: 20)
                 .frame(width: 200, height: 200)
             
             if tracker.isInCooldown {
                 CountdownTimer(endTime: tracker.cooldownEndTime)
                     .padding(.vertical, 8)
             }
             
             Button(action: {
                 // First ensure we have entries
                 if tracker.todayEntries.isEmpty {
                     tracker.generateSchedule()
                 }
                 
                 // Find first incomplete entry
                 if let nextEntry = tracker.todayEntries.first(where: { !$0.completed }) {
                     tracker.logEntry(for: nextEntry)
                 } else {
                     // If no incomplete entries but can still log (e.g., no cooldown), create a new entry
                     if tracker.canLogEntry() && tracker.todayEntries.count < tracker.goal.targetCount {
                         let newEntry = GoalEntry(
                             goalId: tracker.goal.id,
                             scheduledTime: Date()
                         )
                         tracker.todayEntries.append(newEntry)
                         tracker.logEntry(for: newEntry)
                     }
                 }
             }) {
                 Text("Log \(tracker.goal.title)")
                     .padding()
                     .background(tracker.canLogEntry() ? tracker.goal.colorScheme.primary : Color.gray)
                     .foregroundColor(.white)
                     .cornerRadius(10)
             }
             .disabled(!tracker.canLogEntry())
         }
         .onAppear {
             progress = tracker.getProgress()
         }
         .onChange(of: tracker.todayEntries) {
             withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
                 progress = tracker.getProgress()
             }
         }
     }
 }
 
 
struct CountdownTimer: View {
    let endTime: Date
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeString(from: timeRemaining))
            .font(.subheadline)
            .foregroundColor(.gray)
            .onAppear {
                timeRemaining = endTime.timeIntervalSinceNow
            }
            .onReceive(timer) { _ in
                timeRemaining = endTime.timeIntervalSinceNow
            }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        if timeInterval <= 0 { return "Ready!" }
        
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}


//preview function


 struct GoalTrackerView_Preview: View {
      var body: some View {
          GoalTrackerView(tracker: GoalTracker(
              goal: Goal(
                  title: "Take Breaks",
                  targetCount: 5,
                  intervalInSeconds: 2 * 3600, // 2 hours
                  colorScheme: .orange,
                  startTime: Calendar.current.startOfDay(for: Date())
              ), analyticsManager: AnalyticsManager()
          ))
      }
  }


  #Preview {
      GoalTrackerView_Preview()
  }
  
 

