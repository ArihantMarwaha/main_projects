import SwiftUI

struct RewardsView: View {
    @ObservedObject var rewardSystem: RewardSystem
    @State private var selectedFilter: AchievementType?
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showingProgress = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    if rewardSystem.achievements.isEmpty {
                        emptyStateView
                    } else {
                        achievementsContent
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 80)
            }
            
            progressBar
                .background(Color(.systemBackground))
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingProgress) {
            AchievementProgressView(achievements: rewardSystem.achievements)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow.opacity(0.5))
            
            Text("No Achievements Yet")
                .font(.headline)
            
            Text("Complete goals to earn achievements!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var achievementsContent: some View {
        VStack(spacing: 20) {
            AchievementStatsView(rewardSystem: rewardSystem)
            
            achievementFilters
            
            achievementsGrid
        }
    }
    
    private var achievementFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterButton(title: "All", isSelected: selectedFilter == nil) {
                    withAnimation {
                        selectedFilter = nil
                    }
                }
                
                ForEach(AchievementType.allCases, id: \.self) { type in
                    FilterButton(title: type.rawValue,
                               isSelected: selectedFilter == type) {
                        withAnimation {
                            selectedFilter = type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var achievementsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 15) {
            ForEach(filteredAchievements) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
        .padding(.horizontal)
    }
    
    private var filteredAchievements: [Achievement] {
        guard let filter = selectedFilter else { return rewardSystem.achievements }
        return rewardSystem.achievements.filter { $0.type == filter }
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(rewardSystem.achievements.count)")
                        .font(.title2.bold())
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(completedCount)")
                        .font(.title2.bold())
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: { showingProgress = true }) {
                    VStack(spacing: 4) {
                        Text("\(Int(overallProgress * 100))%")
                            .font(.title2.bold())
                        Text("Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
    
    private var completedCount: Int {
        rewardSystem.achievements.filter { $0.isCompleted }.count
    }
    
    private var overallProgress: Double {
        Double(completedCount) / Double(max(1, rewardSystem.achievements.count))
    }
}

// Supporting Views...
struct AchievementStatsView: View {
    @ObservedObject var rewardSystem: RewardSystem
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Achievement Progress")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatBox(title: "Total", value: "\(rewardSystem.achievements.count)")
                StatBox(title: "This Week", value: "\(weeklyAchievements)")
                StatBox(title: "Completion", value: "\(completionRate)%")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var weeklyAchievements: Int {
        let calendar = Calendar.current
        let weekStart = calendar.startOfWeek()
        return rewardSystem.achievements.filter { 
            calendar.isDate($0.dateEarned, inSameDayAs: weekStart) 
        }.count
    }
    
    private var completionRate: Int {
        let completed = rewardSystem.achievements.filter { $0.isCompleted }.count
        return Int((Double(completed) / Double(rewardSystem.achievements.count)) * 100)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.type.icon)
                .font(.title)
                .foregroundColor(achievement.isCompleted ? .yellow : .gray)
            
            Text(achievement.type.rawValue)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(achievement.level.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !achievement.isCompleted {
                ProgressView(value: achievement.progress)
                    .progressViewStyle(.linear)
            }
            
            Text(achievement.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.tertiarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 80)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(8)
    }
} 