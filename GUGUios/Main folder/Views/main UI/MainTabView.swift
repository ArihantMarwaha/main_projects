//
//  MainTabView.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI
import SwiftData
import Charts

struct MainTabView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var selectedTab = 0
    @State private var showingAnalytics = false
    @State private var selectedGoal: Goal?
    @State private var weeklyOverviewRefreshID = UUID()
    @State private var cachedWeeklyStats: [(Goal, WeeklyAnalytics)] = []
    @State private var lastStatsUpdate = Date.distantPast
    
    // Cache expensive computation to prevent UI hangs
    private var weeklyStats: [(Goal, WeeklyAnalytics)] {
        let now = Date()
        // Only recompute if cache is older than 5 seconds
        if now.timeIntervalSince(lastStatsUpdate) < 5.0 && !cachedWeeklyStats.isEmpty {
            return cachedWeeklyStats
        }
        
        return computeWeeklyStats()
    }
    
    private func computeWeeklyStats() -> [(Goal, WeeklyAnalytics)] {
        // First, get all default goals
        let defaultGoals = goalsManager.goals.filter { $0.isDefault }
        
        // Then get all goals with analytics
        let goalsWithAnalytics = goalsManager.goals.compactMap { goal in
            if let analytics = goalsManager.analyticsManager.weeklyAnalytics[goal.id] {
                return (goal, analytics)
            }
            return nil
        }
        
        // For default goals without analytics, create empty analytics
        let defaultGoalsWithAnalytics = defaultGoals.map { goal in
            if let existing = goalsWithAnalytics.first(where: { $0.0.id == goal.id }) {
                return existing
            } else {
                // Create empty analytics for default goal
                let emptyAnalytics = WeeklyAnalytics(
                    id: UUID(),
                    weekStartDate: Calendar.current.startOfWeek(),
                    goalId: goal.id,
                    dailyData: (0..<7).map { day in
                        let date = Calendar.current.date(
                            byAdding: .day,
                            value: day,
                            to: Calendar.current.startOfWeek()
                        ) ?? Date()
                        return DailyProgressData(
                            id: UUID(),
                            date: date,
                            goalId: goal.id,
                            completedCount: 0,
                            targetCount: goal.targetCount,
                            completionTime: []
                        )
                    }
                )
                return (goal, emptyAnalytics)
            }
        }
        
        // Combine default goals with other goals that have analytics
        let nonDefaultGoalsWithAnalytics = goalsWithAnalytics.filter { !$0.0.isDefault }
        let result = defaultGoalsWithAnalytics + nonDefaultGoalsWithAnalytics
        
        // Update cache (already on MainActor)
        cachedWeeklyStats = result
        lastStatsUpdate = Date()
        
        return result
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            PetView(petManager: goalsManager.petActivityManager)
                .tabItem {
                    Label("Pet", systemImage: "heart.fill")
                }
                .tag(0)
            
            GoalDashboardView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(1)
            
            MainJournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.pages.fill")
                }
                .tag(2)
            
           
            WeeklyOverview(weeklyStats: weeklyStats)
                .id(weeklyOverviewRefreshID)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            // Invalidate cache when goals are updated
            lastStatsUpdate = Date.distantPast
            weeklyOverviewRefreshID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: .analyticsDidUpdate)) { _ in
            // Invalidate cache when analytics are updated
            lastStatsUpdate = Date.distantPast
            weeklyOverviewRefreshID = UUID()
        }
    }
}

// MARK: - Weekly Overview
struct WeeklyOverview: View {
    @EnvironmentObject var goalsManager: GoalsManager
    let weeklyStats: [(Goal, WeeklyAnalytics)]
    @State private var showingAnimation = false
    @State private var selectedGoal: Goal?
    @State private var isEditMode = false
    @State private var selectedGoals: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            List {
                // Overall Progress Section
                Section {
                    CompactProgressCard(stats: weeklyStats)
                        .listRowInsets(EdgeInsets())
                }
                
                // Goals Section
                Section {
                    ForEach(weeklyStats, id: \.0.id) { goal, analytics in
                        CompactGoalRow(
                            goal: goal,
                            analytics: analytics,
                            isEditMode: isEditMode,
                            isSelected: selectedGoals.contains(goal.id),
                            onSelect: { toggleSelection(goal: goal) }
                        )
                        .disabled(isEditMode && goal.isDefault)
                    }
                } header: {
                    Text("Goals")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .id(refreshID)
            .navigationTitle("Weekly Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !weeklyStats.isEmpty {
                        Button(isEditMode ? "Done" : "Edit") {
                            withAnimation {
                                isEditMode.toggle()
                                if !isEditMode {
                                    selectedGoals.removeAll()
                                }
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditMode && !selectedGoals.isEmpty {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .alert("Delete Goals", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteSelectedGoals()
                }
            } message: {
                Text("Are you sure you want to delete \(selectedGoals.count) goal\(selectedGoals.count > 1 ? "s" : "")? This action cannot be undone.")
            }
            .onAppear {
                refreshID = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
                withAnimation {
                    refreshID = UUID()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .analyticsDidUpdate)) { _ in
                withAnimation {
                    refreshID = UUID()
                }
            }
        }
    }
    
    private func toggleSelection(goal: Goal) {
        guard !goal.isDefault else { return }
        withAnimation {
            if selectedGoals.contains(goal.id) {
                selectedGoals.remove(goal.id)
            } else {
                selectedGoals.insert(goal.id)
            }
        }
    }
    
    private func deleteSelectedGoals() {
        withAnimation {
            for goalId in selectedGoals {
                if let goalToDelete = weeklyStats.first(where: { $0.0.id == goalId })?.0,
                   !goalToDelete.isDefault {
                    goalsManager.deleteGoal(goalToDelete)
                }
            }
            selectedGoals.removeAll()
            isEditMode = false
            refreshID = UUID()
        }
    }
}

// MARK: - Compact Progress Card
struct CompactProgressCard: View {
    let stats: [(Goal, WeeklyAnalytics)]
    
    private var averageCompletion: Double {
        guard !stats.isEmpty else { return 0 }
        let total = stats.reduce(0.0) { $0 + $1.1.weeklyCompletionRate }
        return total / Double(stats.count)
    }
    
    private var totalCompletions: Int {
        stats.reduce(0) { sum, stat in
            sum + stat.1.dailyData.reduce(0) { $0 + $1.completedCount }
        }
    }
    
    private var perfectGoals: Int {
        stats.filter { $0.1.weeklyCompletionRate >= 1.0 }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Ring and Main Stats
            HStack(alignment: .center, spacing: 20) {
                ZStack {
                    CircularProgressView(
                        progress: averageCompletion,
                        colorScheme: .blue
                    )
                    .frame(width: 80, height: 80)
                    
                    Text("\(Int(averageCompletion * 100))%")
                        .font(.system(.title2, design: .rounded))
                        .bold()
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weekly Progress")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Label(
                        "\(stats.count) Active Goals",
                        systemImage: "target"
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Stats Row
            HStack(spacing: 0) {
                StatBadge(
                    value: "\(totalCompletions)",
                    label: "Completions",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .padding(.horizontal)
                
                StatBadge(
                    value: "\(perfectGoals)",
                    label: "Perfect Goals",
                    icon: "star.fill",
                    color: .yellow
                )
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(.primary)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Compact Goal Row
struct CompactGoalRow: View {
    @EnvironmentObject var goalsManager: GoalsManager
    let goal: Goal
    let analytics: WeeklyAnalytics
    let isEditMode: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var refreshTrigger = UUID()
    
    var body: some View {
        HStack(spacing: 12) {
            if isEditMode {
                Button(action: onSelect) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(goal.isDefault ? .gray : .blue)
                        .imageScale(.large)
                }
                .disabled(goal.isDefault)
            }
            
            NavigationLink {
                // Show different views based on goal type
                if goal.title == "Meals & Snacks" {
                    MealProgressOverview(goal: goal, analytics: analytics)
                } else {
                    WeeklyProgressView(analytics: analytics)
                }
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(goal.colorScheme.primary)
                        .frame(width: 8, height: 8)
                    
                    Text(goal.title)
                        .font(.body)
                    
                    Spacer()
                    
                    Text("\(goalsManager.getProgress(for: goal))/\(goal.targetCount)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
            }
            .disabled(isEditMode)
        }
        .id(refreshTrigger)
        .opacity(isEditMode && goal.isDefault ? 0.6 : 1.0)
        .onReceive(NotificationCenter.default.publisher(for: .analyticsDidUpdate)) { _ in
            refreshTrigger = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            refreshTrigger = UUID()
        }
    }
}





// MARK: - Supporting Views
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
        }
    }
}


// MARK: - Analytics View
struct AnalyticsView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var refreshID = UUID()
    @State private var isEditMode = false
    @State private var selectedGoals: Set<UUID> = []
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if goalsManager.goals.isEmpty {
                    EmptyAnalyticsView()
                } else {
                    AnalyticsListView(
                        isEditMode: $isEditMode,
                        selectedGoals: $selectedGoals,
                        showingDeleteAlert: $showingDeleteAlert,
                        refreshID: refreshID
                    )
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                AnalyticsToolbar(
                    isEditMode: $isEditMode,
                    selectedGoals: $selectedGoals,
                    showingDeleteAlert: $showingDeleteAlert,
                    hasGoals: !goalsManager.goals.isEmpty
                )
            }
            .alert("Delete Goals", isPresented: $showingDeleteAlert) {
                DeleteGoalsAlert(
                    selectedCount: selectedGoals.count,
                    onDelete: deleteSelectedGoals
                )
            }
            .refreshable {
                goalsManager.analyticsManager.loadData()
            }
            .onReceive(NotificationCenter.default.publisher(for: .analyticsDidUpdate)) { _ in
                withAnimation {
                    refreshID = UUID()
                }
            }
        }
    }
    
    private func deleteSelectedGoals() {
        withAnimation {
            let goalsToDelete = goalsManager.goals.filter {
                selectedGoals.contains($0.id) && !$0.isDefault
            }
            for goal in goalsToDelete {
                goalsManager.deleteGoal(goal)
            }
            selectedGoals.removeAll()
            isEditMode = false
        }
    }
}

// MARK: - Analytics List View
struct AnalyticsListView: View {
    @EnvironmentObject var goalsManager: GoalsManager
    @Binding var isEditMode: Bool
    @Binding var selectedGoals: Set<UUID>
    @Binding var showingDeleteAlert: Bool
    let refreshID: UUID
    
    var body: some View {
                    List {
            ForEach(goalsManager.goals) { goal in
                if let analytics = goalsManager.analyticsManager.weeklyAnalytics[goal.id] {
                    AnalyticsRowView(
                        goal: goal,
                        analytics: analytics,
                        isEditMode: isEditMode,
                        isSelected: selectedGoals.contains(goal.id),
                        onSelect: { toggleSelection(for: goal) }
                    )
                }
            }
        }
        .id(refreshID)
    }
    
    private func toggleSelection(for goal: Goal) {
        guard isEditMode && !goal.isDefault else { return }
        if selectedGoals.contains(goal.id) {
            selectedGoals.remove(goal.id)
        } else {
            selectedGoals.insert(goal.id)
        }
    }
}

// MARK: - Analytics Row View
struct AnalyticsRowView: View {
    let goal: Goal
    let analytics: WeeklyAnalytics
    let isEditMode: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        NavigationLink {
            if goal.title == "Meals & Snacks" {
                MealProgressOverview(goal: goal, analytics: analytics)
            } else {
                WeeklyProgressView(analytics: analytics)
            }
        } label: {
            HStack {
                if isEditMode {
                    SelectionIndicator(
                        isSelected: isSelected,
                        isDefault: goal.isDefault
                    )
                }
                
                RowContent(
                    goal: goal,
                    completionRate: analytics.weeklyCompletionRate
                )
            }
            .padding(.vertical, 4)
        }
        .disabled(isEditMode)
        .onTapGesture(perform: onSelect)
        .opacity(isEditMode && goal.isDefault ? 0.5 : 1.0)
    }
}

// MARK: - Supporting Views
struct SelectionIndicator: View {
    let isSelected: Bool
    let isDefault: Bool
    
    var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .foregroundColor(isDefault ? .gray : .blue)
            .imageScale(.large)
    }
}

struct RowContent: View {
    let goal: Goal
    let completionRate: Double
    
    var body: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundColor(goal.colorScheme.primary)
            Text(goal.title)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(Int(completionRate * 100))%")
                    .font(.headline)
                Text("This Week")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AnalyticsToolbar: ToolbarContent {
    @Binding var isEditMode: Bool
    @Binding var selectedGoals: Set<UUID>
    @Binding var showingDeleteAlert: Bool
    let hasGoals: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if hasGoals {
                Button(isEditMode ? "Done" : "Edit") {
                    withAnimation {
                        isEditMode.toggle()
                        if !isEditMode {
                            selectedGoals.removeAll()
                        }
                    }
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            if isEditMode && !selectedGoals.isEmpty {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct DeleteGoalsAlert: View {
    let selectedCount: Int
    let onDelete: () -> Void
    
    var body: some View {
        Group {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
    
    var message: String {
        "Are you sure you want to delete \(selectedCount) goal\(selectedCount > 1 ? "s" : "")? This action cannot be undone."
    }
}

struct EmptyAnalyticsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No Analytics Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete some goals to see your progress analytics")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}




// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // Create temporary ModelContext for preview
        let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let modelContext = container.mainContext
        
        let manager = GoalsManager(modelContext: modelContext)
        MainTabView()
            .environmentObject(manager)
    }
}







