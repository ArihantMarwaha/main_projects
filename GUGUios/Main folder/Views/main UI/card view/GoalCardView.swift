//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import SwiftData

struct GoalCardView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    let goal: Goal
    let tracker: GoalTracker?
    let onLongPress: ((Goal, GoalTracker?) -> Void)?
    let onDragUpdate: ((Goal, GoalTracker?, CGPoint) -> Void)?
    let onGestureEnd: ((Goal, GoalTracker?) -> Void)?
    @State private var progress: Double
    @State private var showingEditSheet = false
    @State private var isLongPressing = false
    @State private var shouldNavigate = false
    
    init(goal: Goal, tracker: GoalTracker?, onLongPress: ((Goal, GoalTracker?) -> Void)? = nil, onDragUpdate: ((Goal, GoalTracker?, CGPoint) -> Void)? = nil, onGestureEnd: ((Goal, GoalTracker?) -> Void)? = nil) {
        self.goal = goal
        self.tracker = tracker
        self.onLongPress = onLongPress
        self.onDragUpdate = onDragUpdate
        self.onGestureEnd = onGestureEnd
        self._progress = State(initialValue: tracker?.getProgress() ?? 0)
    }
    
    var body: some View {
        ZStack {
            // Hidden NavigationLink
            NavigationLink(destination: destinationView, isActive: $shouldNavigate) {
                EmptyView()
            }
            .opacity(0)
            
            // Card content
            cardContent
                .scaleEffect(isLongPressing ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isLongPressing)
                .gesture(
                    combineGestures()
                )
        }
        .onAppear {
            updateProgress()
        }
        .onChange(of: tracker?.todayEntries ?? []) {
            updateProgress()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            updateProgress()
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if goal.requiresSpecialInterface {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("Timer Required")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                if goal.requiresSpecialInterface {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                        .font(.title2)
                } else if !goal.isDefault {
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
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
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
    
    private var destinationView: some View {
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
            } else if goal.title == "Take Breaks" {
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
    }
    
    private func updateProgress() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8)) {
            progress = tracker?.getProgress() ?? 0
        }
    }
    
    private func combineGestures() -> some Gesture {
        let tap = TapGesture()
            .onEnded {
                if !isLongPressing {
                    shouldNavigate = true
                }
            }
        
        let longPress = LongPressGesture(minimumDuration: 1.0, maximumDistance: 50)
            .onChanged { _ in
                // Only activate for non-locked goals
                guard !goal.requiresSpecialInterface else { return }
                
                // Long press activated
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.1)) {
                    isLongPressing = true
                }
                onLongPress?(goal, tracker)
            }
        
        let drag = DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                if isLongPressing && !goal.requiresSpecialInterface {
                    onDragUpdate?(goal, tracker, value.location)
                }
            }
            .onEnded { _ in
                if isLongPressing && !goal.requiresSpecialInterface {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isLongPressing = false
                    }
                    onGestureEnd?(goal, tracker)
                }
            }
        
        return tap.exclusively(before: longPress.simultaneously(with: drag))
    }
}

struct GoalCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create temporary ModelContext for preview
        let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let modelContext = container.mainContext
        
        let previewManager = GoalsManager(modelContext: modelContext)
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
