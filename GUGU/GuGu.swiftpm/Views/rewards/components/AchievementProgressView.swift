import SwiftUI

struct AchievementProgressView: View {
    let achievements: [Achievement]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(AchievementType.allCases, id: \.self) { type in
                    Section(type.rawValue) {
                        ForEach(achievements.filter { $0.type == type }) { achievement in
                            AchievementProgressRow(achievement: achievement)
                        }
                    }
                }
            }
            .navigationTitle("Achievement Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct AchievementProgressRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            Image(systemName: achievement.type.icon)
                .foregroundColor(achievement.isCompleted ? .yellow : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.level.name)
                    .font(.subheadline)
                
                ProgressView(value: achievement.progress)
                    .progressViewStyle(.linear)
                    .tint(achievement.isCompleted ? .yellow : .blue)
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Text("\(Int(achievement.progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
} 