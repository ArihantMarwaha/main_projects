import SwiftUI
import SwiftData
import Charts


struct PetView: View {
    @ObservedObject var petManager: PetActivityManager
    @EnvironmentObject var goalsManager: GoalsManager
    @State private var showingNameEdit = false
    @State private var newName = ""
    
    // Animation states
    @State private var currentFrameIndex = 0
    @State private var isAnimating = true
    @State private var isReversed = false
    
    // Navigation states for quick actions
    @State private var showingWaterTracker = false
    @State private var showingMealTracker = false
    @State private var showingBreakTracker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                animatedBackgroundGradient
                
                VStack(spacing: 24) {
                    petHeaderSection
                    
                    petDisplaySection
                    
                    petStatsSection
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingWaterTracker) {
                if let waterTracker = getWaterTracker() {
                    NavigationView {
                        WaterTrackerView(tracker: waterTracker)
                            .navigationTitle("Water Intake")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingWaterTracker = false
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showingMealTracker) {
                if let mealTracker = getMealTracker() {
                    NavigationView {
                        MealTrackerView(tracker: mealTracker)
                            .navigationTitle("Meals & Snacks")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingMealTracker = false
                                    }
                                }
                            }
                    }
                }
            }
            .sheet(isPresented: $showingBreakTracker) {
                if let breakTracker = getBreakTracker() {
                    NavigationView {
                        BreakTrackerView(tracker: breakTracker)
                            .navigationTitle("Take Breaks")
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingBreakTracker = false
                                    }
                                }
                            }
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
    
    private var animatedBackgroundGradient: some View {
        LinearGradient(
            colors: [moodColor.opacity(0.15), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        ).ignoresSafeArea()
    }
    
    private var petHeaderSection: some View {
        VStack(spacing: 16) {
            // Pet Name - Centered
            Button(action: { showingNameEdit = true }) {
                HStack(spacing: 10) {
                    Text(petManager.petData.name.isEmpty ? "Name your pet" : petManager.petData.name)
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.top, 12)
    }
    
    private var petDisplaySection: some View {
        VStack(spacing: 18) {
            // Pet Avatar with perfect frame
            ZStack {
                // Main container
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .frame(width: 280, height: 280)
                    .shadow(color: moodColor.opacity(0.2), radius: 20, x: 0, y: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(moodColor.opacity(0.15), lineWidth: 1)
                    )
                
                // Pet image with perfect fit and rounded corners
                ZStack {
                    // Inner background for pet
                    RoundedRectangle(cornerRadius: 20)
                        .fill(moodColor.opacity(0.08))
                        .frame(width: 240, height: 240)
                    
                    // Pet animation with rounded corners
                    getCurrentFrame()
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            // Mood indicator with better spacing
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(moodColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: moodIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(moodColor)
                }
                
                Text(petManager.petData.mood)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .overlay(
                        Capsule()
                            .stroke(moodColor.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    
    private var petStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Pet Status")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // Stats container with better spacing
            HStack(spacing: 0) {
                // Energy
                Button(action: { showingBreakTracker = true }) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.25), Color.green.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(petManager.petData.energy)%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Energy")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 1, height: 80)
                
                // Hydration
                Button(action: { showingWaterTracker = true }) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.25), Color.blue.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "drop.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(petManager.petData.hydration)%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Hydration")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Divider
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 1, height: 80)
                
                // Satiation
                Button(action: { showingMealTracker = true }) {
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.25), Color.orange.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                            
                            Image(systemName: "fork.knife")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(petManager.petData.satisfaction)%")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Satiation")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
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
    
    
    private var moodIcon: String {
        switch petManager.petData.state {
        case .happy: return "face.smiling"
        case .ideal: return "star.fill"
        case .sleepy: return "moon.fill"
        case .passedout: return "zzz"
        case .hungry: return "fork.knife"
        case .play: return "gamecontroller.fill"
        }
    }
    
    private func getWaterTracker() -> WaterGoalTracker? {
        return goalsManager.trackers.values.first { tracker in
            tracker.goal.title == "Water Intake"
        } as? WaterGoalTracker
    }
    
    private func getMealTracker() -> MealGoalTracker? {
        return goalsManager.trackers.values.first { tracker in
            tracker.goal.title == "Meals & Snacks"
        } as? MealGoalTracker
    }
    
    private func getBreakTracker() -> BreakGoalTracker? {
        return goalsManager.trackers.values.first { tracker in
            tracker.goal.title == "Take Breaks"
        } as? BreakGoalTracker
    }
    
    private func getProgress(for goalTitle: String) -> Int {
        if let goal = goalsManager.goals.first(where: { $0.title == goalTitle }) {
            return goalsManager.getProgress(for: goal)
        }
        return 0
    }
    
    private func getTarget(for goalTitle: String) -> Int {
        if let goal = goalsManager.goals.first(where: { $0.title == goalTitle }) {
            return goal.targetCount
        }
        return 1
    }
    
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
        isAnimating = true
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

// MARK: - PSP Wave Pattern
struct PSPWavePattern: View {
    let color: Color
    let opacity: Double
    let offset: CGFloat
    let size: CGFloat
    let spacing: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Create enough tiles to cover screen with overlap for seamless animation
            let tilesX = Int((screenWidth / spacing).rounded(.up)) + 3
            let tilesY = Int((screenHeight / spacing).rounded(.up)) + 3
            
            ForEach(0..<tilesY, id: \.self) { row in
                ForEach(0..<tilesX, id: \.self) { col in
                    waveSquare(
                        row: row, 
                        col: col,
                        screenWidth: screenWidth,
                        screenHeight: screenHeight
                    )
                }
            }
        }
        .clipped()
    }
    
    @ViewBuilder
    private func waveSquare(row: Int, col: Int, screenWidth: CGFloat, screenHeight: CGFloat) -> some View {
        // Create infinite tiling effect using modulo for seamless repetition
        let wavePhaseX = (offset + CGFloat(row) * 0.5).truncatingRemainder(dividingBy: .pi * 2)
        let wavePhaseY = (offset + CGFloat(col) * 0.3).truncatingRemainder(dividingBy: .pi * 2)
        let rotationPhase = (offset + CGFloat(row + col) * 0.2).truncatingRemainder(dividingBy: .pi * 2)
        
        // Calculate wave offsets for smooth animation
        let xWaveOffset = sin(wavePhaseX) * 15
        let yWaveOffset = cos(wavePhaseY) * 15
        let rotation = sin(rotationPhase) * 10
        
        // Base grid position with wrapping for infinite scroll effect
        let gridBaseX = (CGFloat(col) * spacing - spacing).truncatingRemainder(dividingBy: screenWidth + spacing * 2)
        let gridBaseY = (CGFloat(row) * spacing - spacing).truncatingRemainder(dividingBy: screenHeight + spacing * 2)
        
        let finalX = gridBaseX + xWaveOffset
        let finalY = gridBaseY + yWaveOffset
        
        // Always render - no culling needed since we're using modulo positioning
        RoundedRectangle(cornerRadius: size * 0.3)
            .fill(color.opacity(opacity))
            .frame(width: size, height: size)
            .position(x: finalX, y: finalY)
            .rotationEffect(.degrees(rotation))
    }
}


// MARK: - Supporting Views
struct InteractiveStatCard: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    let progress: Int
    let target: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 3) {
                    Text("\(value)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


#if DEBUG
struct PetView_Previews: PreviewProvider {
    static var previews: some View {
        // Create temporary ModelContext for preview
        let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let modelContext = container.mainContext
        
        let goalsManager = GoalsManager(modelContext: modelContext)
        let manager = PetActivityManager()
        
        PetView(petManager: manager)
            .environmentObject(goalsManager)
    }
}
#endif

