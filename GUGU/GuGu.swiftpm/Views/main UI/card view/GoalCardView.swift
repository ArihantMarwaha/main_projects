//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct GoalCardView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    let goal: Goal
    let tracker: GoalTracker?
    @State private var progress: Double
    @State private var showingEditSheet = false
    
    init(goal: Goal, tracker: GoalTracker?) {
        self.goal = goal
        self.tracker = tracker
        self._progress = State(initialValue: tracker?.getProgress() ?? 0)
    }
    
    var body: some View {
        NavigationLink {
            Group {
                if goal.title == "Water Intake" {
                    WaterTrackerView(
                        tracker: (tracker as? WaterGoalTracker) ?? WaterGoalTracker(
                            goal: goal,
                            analyticsManager: goalsManager.analyticsManager
                        )
                    )
                } else if goal.title == "Meals & Snacks" {
                    MealTrackerView(
                        tracker: (tracker as? MealGoalTracker) ?? MealGoalTracker(
                            goal: goal,
                            analyticsManager: goalsManager.analyticsManager
                        )
                    )
                } else if goal.title == "Daily Meditation" {
                    MeditationTrackerView(
                        tracker: (tracker as? MeditationGoalTracker) ?? MeditationGoalTracker(
                            goal: goal,
                            analyticsManager: goalsManager.analyticsManager
                        )
                    )
                }
                
                else if goal.title == "Take Breaks" {
                    BreakTrackerView(
                        tracker: (tracker as? BreakGoalTracker) ?? BreakGoalTracker(
                            goal: goal,
                            analyticsManager: goalsManager.analyticsManager
                        )
                    )
                } else {
                    GoalTrackerView(
                        tracker: tracker ?? GoalTracker(
                            goal: goal,
                            analyticsManager: goalsManager.analyticsManager
                        )
                    )
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    if !goal.isDefault {
                        Menu {
                            Button {
                                showingEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    goalsManager.deleteGoal(goal)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                        .sheet(isPresented: $showingEditSheet) {
                            GoalEditView(goal: goal)
                                .environmentObject(goalsManager)
                        }
                    }
                }
                
                // Progress Ring with synchronized animations
                HStack {
                    CircularProgressView(
                        progress: progress,
                        colorScheme: goal.colorScheme
                    )
                    .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading) {
                        Text("\(Int(progress * 100))%")
                            .font(.title3)
                            .bold()
                            .contentTransition(.numericText())
                        
                        Text("\(Int(progress * Double(goal.targetCount)))/\(goal.targetCount)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .contentTransition(.numericText())
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8), value: progress)
                
                // Footer
                HStack {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise")
                    Text("\(Int(goal.intervalInSeconds / 3600))h interval")
                    Spacer()
                    Circle()
                        .fill(goal.colorScheme.primary)
                        .frame(width: 12, height: 12)
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            updateProgress()
        }
        .onChange(of: tracker?.todayEntries ?? []) { _ in
            updateProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            updateProgress()
        }
    }
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
            progress = tracker?.getProgress() ?? 0
        }
    }
}

struct GoalCardView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = GoalsManager()
        let sampleGoal = Goal(
            title: "Sample Goal",
            targetCount: 8,
            intervalInSeconds: 3600,
            colorScheme: .blue
        )
        
        let tracker = GoalTracker(
            goal: sampleGoal,
            analyticsManager: previewManager.analyticsManager
        )
        
        return NavigationView {
            Group {
                GoalCardView(
                    goal: sampleGoal,
                    tracker: tracker
                )
                .environmentObject(previewManager)
                .padding()
                .previewDisplayName("Light Mode")
                
                GoalCardView(
                    goal: sampleGoal,
                    tracker: tracker
                )
                .environmentObject(previewManager)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
            }
        }
    }
}

