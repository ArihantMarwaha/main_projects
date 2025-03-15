import SwiftUI

struct RewardDashboardView: View {
    @ObservedObject var rewardSystem: RewardSystem
    @StateObject private var progressionSystem = ProgressionSystem()
    @State private var selectedAchievement: Achievement?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Points and Level Header
                pointsHeader
                    .transition(.move(edge: .top).combined(with: .opacity))
                
                // Achievement Grid
                achievementGrid
                    .transition(.scale.combined(with: .opacity))
                
                // Progress Section
                progressSection
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .sheet(item: $selectedAchievement) { achievement in
            NavigationView {
                AchievementDetailView(achievement: achievement)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: rewardSystem.achievements)
    }
    
    private var pointsHeader: some View {
        HStack(spacing: 20) {
            pointsDisplay
            levelDisplay
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var pointsDisplay: some View {
        VStack(alignment: .leading) {
            Text("Total Points")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(rewardSystem.totalPoints)")
                .font(.title.bold())
        }
    }
    
    private var levelDisplay: some View {
        VStack(alignment: .leading) {
            Text("Current Level")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(progressionSystem.level)")
                .font(.title.bold())
        }
    }
    
    private var achievementGrid: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 160))
        ], spacing: 16) {
            ForEach(rewardSystem.achievements) { achievement in
                AchievementBadge(achievement: achievement)
                    .onTapGesture {
                        withAnimation {
                            selectedAchievement = achievement
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress")
                .font(.headline)
            
            ForEach(AchievementType.allCases, id: \.self) { type in
                if let achievement = rewardSystem.achievements.first(where: { $0.type == type }) {
                    AchievementProgressRow(achievement: achievement)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
} 