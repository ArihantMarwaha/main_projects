import SwiftUI

struct PetView: View {
    @ObservedObject var petManager: PetActivityManager
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var showingNameEdit = false
    @State private var newName = ""
    @State private var showingRewards = false
    
    // Animation states
    @State private var currentFrameIndex = 0
    @State private var isAnimating = true
    @State private var isReversed = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        petStatusSection
                        petStatsSection
                        //dailyGoalsSection
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Your Pet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        RewardDashboardView(rewardSystem: petManager.rewardSystem)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .alert("Name Your Pet", isPresented: $showingNameEdit) {
                nameEditAlert
            }
            .onAppear {
                startPetAnimation()
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [moodColor.opacity(0.15), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea()
    }
    
    private var petStatusSection: some View {
        VStack(spacing: 20) {
            // Pet Name Button
            Button(action: { showingNameEdit = true }) {
                HStack {
                    Text(petManager.petData.name.isEmpty ? "Name your pet" : petManager.petData.name)
                        .font(.title2.bold())
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color(.secondarySystemBackground))
                .clipShape(Capsule())
            }
            
            // Updated Pet Card
            VStack(spacing: 10) {
                ZStack {
                    Color(.secondarySystemBackground)
                        .cornerRadius(10)
                        .shadow(color: Color(.systemGray4), radius: 3, x: 0, y: 2)
                    
                    getCurrentFrame()
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                }
                .frame(height: 320) // Fixed height instead of aspect ratio
                .padding(.horizontal, 40)
                
                // Mood Indicator
                Text(petManager.petData.mood)
                    .font(.headline)
                    .foregroundColor(moodColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(moodColor.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var petStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Pet Status")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                PetStatBadge(label: "Energy", value: petManager.petData.energy, icon: "battery.75", color: .green)
                PetStatBadge(label: "Hydration", value: petManager.petData.hydration, icon: "drop.fill", color: .blue)
                PetStatBadge(label: "Satiation", value: petManager.petData.satisfaction, icon: "fork.knife", color: .orange)
            }
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
    }
    
    
    
    
    /*
     
     private var dailyGoalsSection: some View {
         VStack(spacing: 12) {
             Text("Daily Goals")
                 .font(.subheadline)
                 .foregroundColor(.secondary)
                 .frame(maxWidth: .infinity, alignment: .leading)
             
             ForEach(goalsManager.goals.filter { $0.isDefault }) { goal in
                 GoalProgressRow(
                     goal: goal,
                     progress: goalsManager.getProgress(for: goal),
                     needsAttention: needsAttention(for: goal.title)
                 )
             }
         }
         .padding(.horizontal)
     }
     */
    
    private var nameEditAlert: some View {
        Group {
            TextField("Pet Name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    petManager.setPetName(newName)
                    newName = ""
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func needsAttention(for goalType: String) -> Bool {
        switch goalType {
        case "Water Intake": return petManager.petData.hydration < PetData.Threshold.low
        case "Meals & Snacks": return petManager.petData.satisfaction < PetData.Threshold.low
        case "Take Breaks": return petManager.petData.energy < PetData.Threshold.low
        default: return false
        }
    }
    
    private var moodColor: Color {
        switch petManager.petData.state {
        case .happy: return .green
        case .ideal: return .blue
        case .sleepy: return .purple
        case .passedout: return .gray
        case .hungry: return .orange
        case .play: return .pink
        }
    }
    
    // Animation functions
    private func getCurrentFrame() -> Image {
           let frames = petManager.petData.state.animationFrames
           return frames[currentFrameIndex % frames.count]
       }
    
    private func startPetAnimation() {
        isAnimating = false
        animate()
    }
    
    private func animate() {
        guard isAnimating else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if !isReversed {
                    currentFrameIndex += 1
                    if currentFrameIndex >= petManager.petData.state.animationFrames.count - 1 {
                        isReversed = true
                    }
                } else {
                    currentFrameIndex -= 1
                    if currentFrameIndex <= 0 {
                        isReversed = false
                    }
                }
            }
            animate()
        }
    }
}

// MARK: - Supporting Views
struct PetStatBadge: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text("\(value)%")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.systemGray4).opacity(0.9), radius: 4, x: 0, y: 2)
    }
}

struct GoalProgressRow: View {
    let goal: Goal
    let progress: Int
    let needsAttention: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: iconForGoal(goal.title))
                    .foregroundColor(needsAttention ? .red : goal.colorScheme.primary)
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(progress)/\(goal.targetCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    Rectangle()
                        .fill(needsAttention ? Color.red : goal.colorScheme.primary)
                        .frame(width: geometry.size.width * CGFloat(progress) / CGFloat(goal.targetCount))
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func iconForGoal(_ title: String) -> String {
        switch title {
        case "Water Intake": return "drop.fill"
        case "Meals & Snacks": return "fork.knife"
        case "Take Breaks": return "figure.walk"
        default: return "checkmark.circle"
        }
    }
}

// Add this new Progress Bar component
struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.systemGray5))
                Rectangle()
                    .foregroundColor(.yellow)
                    .frame(width: geometry.size.width * progress)
            }
            .cornerRadius(3)
        }
    }
}

// Preview
struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = PetActivityManager()
        PetView(petManager: manager)
            .environmentObject(GoalsManager())
    }
}

