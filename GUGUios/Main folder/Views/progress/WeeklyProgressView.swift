import SwiftUI
import Charts
import Foundation

struct WeeklyProgressView: View {
    let analytics: WeeklyAnalytics
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var showingDetailView = false
    @State private var selectedGoal: Goal?
    @State private var refreshID = UUID()
    @State private var currentAnalytics: WeeklyAnalytics
    
    private var goal: Goal? {
        goalsManager.goals.first { $0.id == analytics.goalId }
    }
    
    private var mealTracker: MealGoalTracker? {
        goalsManager.trackers[analytics.goalId] as? MealGoalTracker
    }
    
    init(analytics: WeeklyAnalytics) {
        self.analytics = analytics
        _currentAnalytics = State(initialValue: analytics)
    }
    
    var body: some View {
        List {
            // Weekly Overview Section
            Section {
                WeeklySummaryCard(
                    analytics: currentAnalytics,
                    colorScheme: goal?.colorScheme ?? .blue
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            // Stats Section
            Section("Statistics") {
                StatRow(
                    title: "Current Streak",
                    value: "0",
                    icon: "flame.fill",
                    color: goal?.colorScheme.primary ?? .blue
                )
                
                StatRow(
                    title: "Total Completions",
                    value: "\(currentAnalytics.dailyData.reduce(0) { $0 + $1.completedCount })",
                    icon: "checkmark.circle.fill",
                    color: goal?.colorScheme.primary ?? .blue
                )
                
                // Perfect Week stat
                if currentAnalytics.isPerfectWeek {
                    StatRow(
                        title: "Perfect Week",
                        value: "moon.stars",
                        icon: "moon.stars.fill",
                        color: .yellow
                    )
                }
                
                // Perfect Day stat
                if currentAnalytics.isPerfectDay {
                    StatRow(
                        title: "Perfect Day",
                        value: "star",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
                
                if let avgTime = currentAnalytics.averageCompletionTime {
                    StatRow(
                        title: "Average Time",
                        value: formatTime(avgTime),
                        icon: "clock",
                        color: goal?.colorScheme.primary ?? .blue
                    )
                }
                
                // Add meal-specific stats if this is a meal goal
                if goal?.title == "Meals & Snacks",
                   let tracker = mealTracker {
                    let completedMeals = tracker.getTodayCompletedMeals()
                    StatRow(
                        title: "Today's Meals",
                        value: "\(completedMeals.count)/\(MealGoalTracker.MealType.allCases.count)",
                        icon: "fork.knife",
                        color: goal?.colorScheme.primary ?? .orange
                    )
                }
            }
            
            // Today's Progress Section
            if let today = currentAnalytics.dailyData.first(where: { $0.date.isToday }) {
                Section("Today's Progress") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(today.completedCount) of \(today.targetCount)")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(today.completionRate * 100))%")
                                .foregroundColor(goal?.colorScheme.primary ?? .blue)
                                .bold()
                        }
                        
                        // Show meal breakdown if this is a meal goal
                        if goal?.title == "Meals & Snacks",
                           let tracker = mealTracker {
                            Divider()
                            ForEach(MealGoalTracker.MealType.allCases, id: \.self) { mealType in
                                HStack {
                                    Label(mealType.rawValue, systemImage: mealType.icon)
                                        .foregroundColor(mealType.color)
                                    Spacer()
                                    Image(systemName: tracker.isCompleted(mealType) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(tracker.isCompleted(mealType) ? .green : .gray)
                                }
                            }
                        }
                    }
                }
            }
        }
        .id(refreshID)
        .navigationTitle(goal?.title ?? "Weekly Progress")
        .toolbar {
            Button {
                showingDetailView = true
            } label: {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(goal?.colorScheme.primary ?? .blue)
            }
        }
        .sheet(isPresented: $showingDetailView) {
            NavigationView {
                WeeklyDetailView(
                    analytics: currentAnalytics,
                    colorScheme: goal?.colorScheme ?? .blue
                )
                .navigationTitle("Detailed Analysis")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            updateAnalytics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            withAnimation {
                updateAnalytics()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .analyticsDidUpdate)) { _ in
            withAnimation {
                updateAnalytics()
            }
        }
    }
    
    private func updateAnalytics() {
        if let updated = goalsManager.analyticsManager.weeklyAnalytics[analytics.goalId] {
            currentAnalytics = updated
            refreshID = UUID()
        }
        
        // Reward system removed
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return String(format: "%d min", minutes)
        }
    }
}

// MARK: - Supporting Views
struct StatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(color)
        }
    }
}

// MARK: - Detail View
struct WeeklyDetailView: View {
    let analytics: WeeklyAnalytics
    let colorScheme: GoalColorScheme
    @State private var showingAnimation = false
    @State private var selectedDay: DailyProgressData?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Chart {
                    ForEach(analytics.dailyData) { day in
                        BarMark(
                            x: .value("Day", day.date.formatted(.dateTime.weekday(.short))),
                            y: .value("Completion", showingAnimation ? day.completionRate : 0)
                        )
                        .foregroundStyle(day.date.isToday ? colorScheme.primary : colorScheme.primary.opacity(0.6))
                        .annotation(position: .top) {
                            Text("\(Int(day.completionRate * 100))%")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .chartYScale(domain: 0...1)
                
                ForEach(analytics.dailyData) { day in
                    DayRow(dailyData: day, colorScheme: colorScheme)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingAnimation = true
            }
        }
    }
}

struct DayRow: View {
    let dailyData: DailyProgressData
    let colorScheme: GoalColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dailyData.date.formatted(.dateTime.weekday().month().day()))
                .font(.headline)
            
            HStack {
                Text("\(dailyData.completedCount) of \(dailyData.targetCount)")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(dailyData.completionRate * 100))%")
                    .bold()
                    .foregroundColor(colorScheme.primary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

//summary of a single goal 
struct WeeklySummaryCard: View {
    let analytics: WeeklyAnalytics
    let colorScheme: GoalColorScheme
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Weekly Overview")
                        .font(.headline)
                    Text("\(Int(analytics.weeklyCompletionRate * 100))%")
                        .font(.title)
                        .bold()
                        .foregroundColor(colorScheme.primary)
                }
                Spacer()
                CircularProgressView(
                    progress: analytics.weeklyCompletionRate,
                    colorScheme: colorScheme
                )
                .frame(width: 60, height: 60)
            }
            
            if let avgTime = analytics.averageCompletionTime {
                HStack {
                    Label {
                        Text("Average completion time: \(timeString(from: avgTime))")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 2)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: interval)
        return date.formatted(.dateTime.hour().minute())
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}



