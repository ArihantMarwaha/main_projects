import SwiftUI
import Combine

struct MealTrackerView: View {
    @ObservedObject var tracker: MealGoalTracker
    @State private var selectedMeal: MealGoalTracker.MealType?
    @State private var showingMealInfo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Progress Overview
                VStack(spacing: 8) {
                    ProgressRingView(tracker: tracker, ringWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Text("\(tracker.completedMeals.count)/\(tracker.goal.targetCount) meals")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Meal Schedule
                VStack(spacing: 16) {
                    HStack {
                        Text("Today's Meals")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showingMealInfo = true
                        } label: {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ForEach(MealGoalTracker.MealType.allCases, id: \.self) { mealType in
                        MealCardView(
                            mealType: mealType,
                            tracker: tracker
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
            }
            .padding()
        }
        .navigationTitle("Meals & Snacks")
        .sheet(isPresented: $showingMealInfo) {
            MealInfoView()
        }
    }
}

struct MealCardView: View {
    let mealType: MealGoalTracker.MealType
    @ObservedObject var tracker: MealGoalTracker
    @State private var isAnimating = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                if tracker.canLogMeal(mealType) {
                    tracker.logMeal(mealType)
                    isAnimating = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnimating = false
                    }
                }
            }
        } label: {
            HStack {
                // Meal Icon and Name
                HStack(spacing: 12) {
                    Image(systemName: mealType.icon)
                        .font(.title2)
                        .foregroundColor(mealType.color)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mealType.rawValue)
                            .font(.headline)
                        
                        if tracker.isCompleted(mealType) {
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Available")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                StatusIndicator(
                    mealType: mealType,
                    tracker: tracker,
                    isAnimating: isAnimating
                )
            }
            .padding()
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!tracker.canLogMeal(mealType))
        .opacity(1.0)
    }
    
    private var backgroundColor: Color {
        if tracker.isCompleted(mealType) {
            return Color(.systemGray6)
        } else {
            return Color(.systemBackground)
        }
    }
}

struct StatusIndicator: View {
    let mealType: MealGoalTracker.MealType
    let tracker: MealGoalTracker
    let isAnimating: Bool
    
    var body: some View {
        Group {
            if tracker.isCompleted(mealType) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
            } else {
                Image(systemName: "plus.circle")
                    .foregroundColor(.blue)
            }
        }
        .font(.title3)
        .animation(.spring(response: 0.3), value: isAnimating)
    }
}

struct MealInfoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Meal Schedule")) {
                    ForEach(MealGoalTracker.MealType.allCases, id: \.self) { mealType in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mealType.rawValue)
                                .font(.headline)
                            Text("Cooldown: \(Int(mealType.cooldownInterval/3600)) hours")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section(header: Text("About")) {
                    Text("Track your daily meals and snacks to maintain a healthy eating schedule. Each meal has a specific cooldown period to encourage proper meal spacing.")
                }
            }
            .navigationTitle("Meal Information")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationView {
        MealTrackerView(tracker: MealGoalTracker.createDefault(analyticsManager: AnalyticsManager()))
    }
}
