import SwiftUI


struct AchievementBadge: View {
    let achievement: Achievement
    let size: CGFloat
    let isInteractive: Bool
    @State private var isShowingDetail = false
    @State private var isAnimating = false
    @State private var showConfetti = false
    @State private var hasCelebrated = false
    
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
            // Start the pulsing animation if achievement is completed
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).repeatForever(autoreverses: true)) {
                isAnimating = achievement.isCompleted
            }
            
            // Check if we should show confetti celebration:
            // Show confetti only if achievement just completed and not celebrated before
            if achievement.isCompleted && !hasCelebrated {
                let key = "achievement_celebrated_\(achievement.id)"
                let celebrated = UserDefaults.standard.bool(forKey: key)
                if !celebrated {
                    showConfetti = true
                    UserDefaults.standard.setValue(true, forKey: key)
                    hasCelebrated = true
                }
            }
        }
        // Overlay ConfettiView when celebration is active
        .overlay {
            if showConfetti {
                ConfettiView(isPresented: $showConfetti)
                    .frame(width: size * 2, height: size * 2)
                    .allowsHitTesting(false)
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
                    .fill(.ultraThinMaterial)
                    .background(
                        Circle()
                            .fill(backgroundColor)
                    )
                    .frame(width: size, height: size)
                    .shadow(color: achievement.isCompleted ? .yellow.opacity(0.6) : .gray.opacity(0.2),
                            radius: achievement.isCompleted ? 12 : 8,
                            x: 0, y: achievement.isCompleted ? 6 : 4)
                
                Circle()
                    .stroke(achievement.isCompleted ? .yellow : .gray.opacity(0.3),
                            lineWidth: 3)
                    .frame(width: size - 4, height: size - 4)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(achievement.isCompleted ? .yellow : .gray)
                    // Pulsing scale effect for completed badges
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    // Glowing shadow for completed badges
                    .shadow(color: achievement.isCompleted ? .yellow.opacity(0.8) : .clear, radius: 8, x: 0, y: 0)
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
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .cornerRadius(12)
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

