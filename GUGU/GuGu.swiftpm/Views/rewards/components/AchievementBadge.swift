import SwiftUI

struct AchievementBadge: View {
    let achievement: Achievement
    let size: CGFloat
    let isInteractive: Bool
    @State private var isShowingDetail = false
    @State private var isAnimating = false
    
    init(achievement: Achievement, size: CGFloat = 120, isInteractive: Bool = true) {
        self.achievement = achievement
        self.size = size
        self.isInteractive = isInteractive
    }
    
    var body: some View {
        Group {
            if isInteractive {
                interactiveBadge
            } else {
                staticBadge
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                isAnimating = achievement.isCompleted
            }
        }
    }
    
    private var interactiveBadge: some View {
        Button(action: { isShowingDetail = true }) {
            badgeContent
        }
        .sheet(isPresented: $isShowingDetail) {
            NavigationView {
                AchievementDetailView(achievement: achievement)
            }
        }
    }
    
    private var staticBadge: some View {
        badgeContent
    }
    
    private var badgeContent: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)
                    .shadow(color: achievement.isCompleted ? .yellow.opacity(0.3) : .gray.opacity(0.2),
                           radius: 8, x: 0, y: 4)
                
                Circle()
                    .stroke(achievement.isCompleted ? .yellow : .gray.opacity(0.3),
                           lineWidth: 3)
                    .frame(width: size - 4, height: size - 4)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(achievement.isCompleted ? .yellow : .gray)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            VStack(spacing: 4) {
                Text(achievement.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text(levelText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var backgroundColor: Color {
        achievement.isCompleted ? .yellow.opacity(0.1) : .gray.opacity(0.1)
    }
    
    private var levelText: String {
        switch achievement.level {
        case .bronze: return "🥉 Bronze"
        case .silver: return "🥈 Silver"
        case .gold: return "🥇 Gold"
        case .platinum: return "💎 Platinum"
        }
    }
} 