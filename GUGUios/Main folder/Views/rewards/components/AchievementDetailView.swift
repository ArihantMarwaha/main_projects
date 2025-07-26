import SwiftUI

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Badge Section
                badgeSection
                
                // Details Section
                detailsSection
                
                // Description Section
                descriptionSection
                
                if !achievement.isCompleted {
                    tipsSection
                }
            }
            .padding()
        }
        .navigationTitle("Achievement Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var badgeSection: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(achievement.isCompleted ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: 50))
                    .foregroundColor(achievement.isCompleted ? .yellow : .gray)
            }
            
            Text(achievement.type.rawValue)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            
            Text(achievement.level.name)
                .font(.subheadline)
                .foregroundColor(achievement.level.color)
        }
    }
    
    private var detailsSection: some View {
        VStack(spacing: 16) {
            detailRow(title: "Status",
                     value: achievement.isCompleted ? "Completed ✓" : "In Progress...",
                     color: achievement.isCompleted ? .green : .orange)
            
            detailRow(title: "Progress",
                     value: "\(Int(achievement.progress * 100))%",
                     color: .blue)
            
            if achievement.isCompleted {
                detailRow(title: "Earned",
                         value: achievement.formattedDate,
                         color: .purple)
            }
            
            detailRow(title: "Level",
                     value: achievement.level.name,
                     color: achievement.level.color)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
            
            Text(achievement.type.description)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips to Earn")
                .font(.headline)
            
            ForEach(getTips(), id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.blue)
                    Text(tip)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func detailRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
    }
    
    private func getTips() -> [String] {
        switch achievement.type {
        case .waterStreak:
            return ["Track water intake regularly",
                   "Set reminders for water breaks",
                   "Keep a water bottle nearby"]
        case .mealStreak:
            return ["Plan your meals ahead",
                   "Set regular meal times",
                   "Track your snacks"]
        case .breakStreak:
            return ["Take short breaks every hour",
                   "Stand up and stretch",
                   "Go for short walks"]
        default:
            return ["Complete daily goals consistently",
                   "Keep your pet happy",
                   "Maintain good habits"]
        }
    }
} 