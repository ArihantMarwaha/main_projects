import SwiftUI
import Charts

struct MealProgressOverview: View {
    @EnvironmentObject var goalsManager: GoalsManager
    let goal: Goal
    let analytics: WeeklyAnalytics
    
    var mealTracker: MealGoalTracker? {
        goalsManager.trackers[goal.id] as? MealGoalTracker
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Weekly completion rate
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Completion")
                                .font(.headline)
                            Text("\(Int(analytics.weeklyCompletionRate * 100))%")
                                .font(.system(.title, design: .rounded))
                                .bold()
                                .foregroundColor(.orange)
                        }
                        Spacer()
                        CircularProgressView(
                            progress: analytics.weeklyCompletionRate,
                            colorScheme: .orange
                        )
                        .frame(width: 70, height: 70)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // Today's meals
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Meals")
                        .font(.headline)
                    
                    ForEach(MealGoalTracker.MealType.allCases, id: \.self) { mealType in
                        HStack {
                            Image(systemName: mealType.icon)
                                .font(.title3)
                                .foregroundColor(mealType.color)
                            Text(mealType.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if let tracker = mealTracker {
                                Image(systemName: tracker.isCompleted(mealType) ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundColor(tracker.isCompleted(mealType) ? .green : .gray)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // Weekly summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Summary")
                        .font(.headline)
                    
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Meals")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(analytics.totalCompletions) / \(analytics.dailyData.count * goal.targetCount)")
                                .font(.system(.title2, design: .rounded))
                                .bold()
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 8) {
                            Text("Daily Average")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.1f", analytics.averageCompletionsPerDay))
                                .font(.system(.title2, design: .rounded))
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
                
                // Weekly chart
                VStack(alignment: .leading, spacing: 16) {
                    Text("Weekly Progress")
                        .font(.headline)
                    MiniWeeklyChart(analytics: analytics)
                        .frame(height: 120)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Meals & Snacks")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MiniWeeklyChart: View {
    let analytics: WeeklyAnalytics
    @State private var showingAnimation = false
    
    var body: some View {
        Chart {
            ForEach(analytics.dailyData) { day in
                BarMark(
                    x: .value("Day", day.date.formatted(.dateTime.weekday(.short))),
                    y: .value("Completion", showingAnimation ? day.completionRate : 0)
                )
                .foregroundStyle(day.date.isToday ? Color.orange : Color.orange.opacity(0.6))
            }
        }
        .chartYScale(domain: 0...1)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingAnimation = true
            }
        }
    }
} 
