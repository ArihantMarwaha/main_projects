//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import SwiftData
import Charts

struct GoalDashboardView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var showingCreator = false
    @State private var selectedCategory: GoalCategory? = nil
    @State private var searchText = ""
    @State private var showingQuickLog = false
    @State private var selectedGoal: Goal?
    @State private var selectedTracker: GoalTracker?
    @State private var dragLocation: CGPoint = .zero
    @State private var isHoveringButton = false
    @State private var buttonFrame: CGRect = .zero
    
    private var filteredGoals: [Goal] {
        let categoryFiltered = selectedCategory == nil
            ? goalsManager.goals
            : goalsManager.goals
        
        if searchText.isEmpty {
            return categoryFiltered
        }
        
        return categoryFiltered.filter { goal in
            goal.title.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    DailySummaryView(goalsManager: goalsManager)
                        .transition(.scale.combined(with: .opacity))
                    
                    
                    //fot category filteration
                    
                    /*
                     
                     CategoryFilterView(
                         selectedCategory: $selectedCategory,
                         categories: goalsManager.categories
                     )
                     .transition(.slide)
                     */
                  
                    
                    SearchBar(text: $searchText)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredGoals) { goal in
                            GoalCardView(
                                goal: goal,
                                tracker: goalsManager.trackers[goal.id],
                                onLongPress: { goal, tracker in
                                    selectedGoal = goal
                                    selectedTracker = tracker
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        showingQuickLog = true
                                    }
                                },
                                onDragUpdate: { goal, tracker, location in
                                    dragLocation = location
                                    // Check if dragging over the log button area
                                    checkButtonHover(at: location)
                                },
                                onGestureEnd: { goal, tracker in
                                    if isHoveringButton {
                                        handleQuickLog()
                                    }
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showingQuickLog = false
                                        selectedGoal = nil
                                        selectedTracker = nil
                                        isHoveringButton = false
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                            .id(goal.id)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.spring(response: 0.4), value: filteredGoals.map { $0.id })
                }
            }
            .navigationTitle("Daily Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showingCreator = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreator) {
            CustomGoalCreatorView()
                .environmentObject(goalsManager)
        }
        .overlay {
            if showingQuickLog, let goal = selectedGoal {
                QuickLogPopup(
                    goal: goal,
                    tracker: selectedTracker,
                    isHoveringButton: isHoveringButton,
                    onDismiss: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showingQuickLog = false
                            selectedGoal = nil
                            selectedTracker = nil
                            isHoveringButton = false
                        }
                    },
                    onButtonFrameChanged: { frame in
                        buttonFrame = frame
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity.combined(with: .scale(scale: 0.9))
                ))
                .zIndex(1000)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingQuickLog)
            }
        }
    }
    
    private func handleQuickLog() {
        guard let tracker = selectedTracker, let goal = selectedGoal else { return }
        
        // Check if goal requires special interface (like meditation)
        if goal.requiresSpecialInterface {
            print("🔒 Goal \(goal.title) requires special interface - cannot quick log")
            return
        }
        
        // Handle different tracker types appropriately
        if let mealTracker = tracker as? MealGoalTracker {
            // For meal tracker, find the next available meal type
            let availableMeals = MealGoalTracker.MealType.allCases.filter { mealType in
                mealTracker.canLogMeal(mealType)
            }
            
            if let nextMeal = availableMeals.first {
                print("🍽️ Quick logging meal: \(nextMeal.rawValue)")
                mealTracker.logMeal(nextMeal)
            } else {
                print("⚠️ No available meals to log")
            }
        } else {
            // For other trackers (Water, Break, etc.), use improved generic method
            print("🎯 Quick logging for \(goal.title)")
            
            // First ensure we have entries
            if tracker.todayEntries.isEmpty {
                print("📅 No entries found, generating schedule")
                tracker.generateSchedule()
            }
            
            // Find first incomplete entry
            if let nextEntry = tracker.todayEntries.first(where: { !$0.completed }) {
                print("✅ Found incomplete entry, logging...")
                tracker.logEntry(for: nextEntry)
            } else {
                // If no incomplete entries but can still log (e.g., no cooldown), create a new entry
                if tracker.canLogEntry() && tracker.todayEntries.count < goal.targetCount {
                    print("🆕 Creating new entry for logging")
                    let newEntry = GoalEntry(
                        goalId: goal.id,
                        scheduledTime: Date()
                    )
                    tracker.todayEntries.append(newEntry)
                    tracker.logEntry(for: newEntry)
                } else {
                    print("⚠️ Cannot log: goal may be complete or in cooldown")
                }
            }
        }
    }
    
    private func checkButtonHover(at location: CGPoint) {
        // Only check if we have a valid button frame
        guard buttonFrame != .zero else { return }
        
        // Add some padding to make the hover area more generous
        let expandedFrame = buttonFrame.insetBy(dx: -20, dy: -20)
        let newHoverState = expandedFrame.contains(location)
        
        if newHoverState != isHoveringButton {
            withAnimation(.easeInOut(duration: 0.1)) {
                isHoveringButton = newHoverState
            }
            
            if newHoverState {
                // Haptic feedback when entering button area
                let selectionFeedback = UISelectionFeedbackGenerator()
                selectionFeedback.selectionChanged()
            }
        }
    }
}

struct GoalDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create temporary ModelContext for preview
        let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let modelContext = container.mainContext
        
        let previewManager = GoalsManager(modelContext: modelContext)
        
        return Group {
            GoalDashboardView()
                .environmentObject(previewManager)
                .previewDisplayName("Light Mode")
            
            GoalDashboardView()
                .environmentObject(previewManager)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

