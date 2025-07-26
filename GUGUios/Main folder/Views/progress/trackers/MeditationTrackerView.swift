import SwiftUI
import Combine
struct MeditationTrackerView: View {
    @ObservedObject var tracker: MeditationGoalTracker
    @State private var selectedDuration: TimeInterval = 300 // 5 minutes default
    @State private var isTimerRunning = false
    @State private var remainingTime: TimeInterval = 0
    @State private var breathingPhase: BreathingPhase = .inhale
    @State private var showingCompletionView = false
    
    private let availableDurations: [TimeInterval] = [
        60,   // 1 minute
        120,  // 2 minutes
        300,  // 5 minutes
        600,  // 10 minutes
        900,  // 15 minutes
        1200, // 20 minutes
        1800  // 30 minutes
    ]
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let breathingTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var breathingProgress: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 20) {
            if isTimerRunning {
                meditationTimerView
            } else {
                meditationSetupView
            }
        }
        .padding()
        .animation(.easeInOut, value: isTimerRunning)
        .sheet(isPresented: $showingCompletionView) {
            MeditationCompletionView(duration: selectedDuration) {
                if let nextEntry = tracker.todayEntries.first(where: { !$0.completed }) {
                    tracker.logEntry(for: nextEntry)
                }
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    completeSession()
                }
            }
        }
        .onReceive(breathingTimer) { _ in
            if isTimerRunning {
                breathingProgress += 0.1
                if breathingProgress >= breathingPhase.duration {
                    breathingProgress = 0
                    withAnimation {
                        breathingPhase = breathingPhase.nextPhase
                    }
                }
            }
        }
    }
    
    private var meditationSetupView: some View {
        VStack(spacing: 25) {
            // Status Card
            VStack {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.purple)
                    .padding()
                
                Text("Daily Meditation")
                    .font(.title2)
                    .bold()
                
                if tracker.totalSessionsToday > 0 {
                    Text("Sessions today: \(tracker.totalSessionsToday)")
                        .foregroundColor(.secondary)
                } else {
                    Text("Start your first session")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
            
            // Duration Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(availableDurations, id: \.self) { duration in
                        DurationButton(
                            duration: duration,
                            isSelected: selectedDuration == duration,
                            action: { selectedDuration = duration }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Start Button
            Button(action: startMeditation) {
                Text("Start Meditation")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
    }
    
    private var meditationTimerView: some View {
        VStack(spacing: 30) {
            // Breathing Animation
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 2)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .scaleEffect(getBreathingScale())
                    .animation(.easeInOut(duration: 0.7), value: breathingPhase)
                
                VStack(spacing: 8) {
                    Text(timeString(from: remainingTime))
                        .font(.system(size: 48, weight: .thin, design: .rounded))
                        .foregroundColor(.purple)
                    
                    Text(breathingPhase.instruction)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .animation(.easeInOut, value: breathingPhase)
                    
                    // Add progress indicator for current breathing phase
                    Text(String(format: "%.1f", breathingPhase.duration - breathingProgress))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar for breathing phase
            /*GeometryReader { geometry in
             ZStack(alignment: .leading) {
                 Rectangle()
                     .fill(Color.purple.opacity(0.1))
                     .frame(height: 4)
                 
                 Rectangle()
                     .fill(Color.purple)
                     .frame(width: geometry.size.width * CGFloat(breathingProgress / breathingPhase.duration), height: 4)
             }
         }
         .frame(height: 4)
         .padding(.horizontal)*/
            
            // Cancel Button
            Button(action: cancelMeditation) {
                Text("End Session")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple.opacity(0.3))
                    .foregroundColor(.purple)
                    .cornerRadius(20)
            }
            .padding(.horizontal)
        }
    }
    
    private func getBreathingScale() -> CGFloat {
        switch breathingPhase {
        case .inhale:
            return 1.0 + (0.2 * CGFloat(breathingProgress / breathingPhase.duration))
        case .holdInhale:
            return 1.2
        case .exhale:
            return 1.2 - (0.2 * CGFloat(breathingProgress / breathingPhase.duration))
        case .holdExhale:
            return 1.0
        }
    }
    
    private func startMeditation() {
        remainingTime = selectedDuration
        isTimerRunning = true
        breathingPhase = .inhale
        breathingProgress = 0
    }
    
    private func cancelMeditation() {
        isTimerRunning = false
        remainingTime = 0
        breathingPhase = .inhale
        breathingProgress = 0
    }
    
    private func completeSession() {
        isTimerRunning = false
        remainingTime = 0
        showingCompletionView = true
        
        // Log the meditation session
        tracker.logMeditationSession(duration: selectedDuration)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views and Types
struct DurationButton: View {
    let duration: TimeInterval
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text("\(Int(duration/60))")
                    .font(.title2.bold())
                Text("min")
                    .font(.caption)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color.purple : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(15)
            .animation(.spring(), value: isSelected)
        }
    }
}

struct MeditationCompletionView: View {
    let duration: TimeInterval
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding()
            
            Text("Great job!")
                .font(.title)
                .bold()
            
            Text("You've completed \(Int(duration/60)) minutes of meditation")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button(action: {
                    onComplete()
                    dismiss()
                }) {
                    Text("Done")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Meditate Again")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
        }
        .padding()
    }
}

enum BreathingPhase {
    case inhale
    case holdInhale
    case exhale
    case holdExhale
    
    var instruction: String {
        switch self {
        case .inhale: return "Breathe In"
        case .holdInhale: return "Hold"
        case .exhale: return "Breathe Out"
        case .holdExhale: return "Hold"
        }
    }
    
    var duration: TimeInterval {
        switch self {
        case .inhale: return 3    // 6 seconds to breathe in
        case .holdInhale: return 5 // 5 seconds to hold
        case .exhale: return 4    // 4 seconds to breathe out
        case .holdExhale: return 4 // 4 seconds to hold
        }
    }
    
    var nextPhase: BreathingPhase {
        switch self {
        case .inhale: return .holdInhale
        case .holdInhale: return .exhale
        case .exhale: return .holdExhale
        case .holdExhale: return .inhale
        }
    }
}

// MARK: - Preview
struct MeditationTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        let goal = Goal(
            title: "Daily Meditation",
            targetCount: 1,
            intervalInSeconds: TrackerConstants.dayInSeconds,
            colorScheme: .purple,
            isDefault: true
        )
        let analyticsManager = AnalyticsManager()
        let tracker = MeditationGoalTracker(goal: goal, analyticsManager: analyticsManager)
        
        MeditationTrackerView(tracker: tracker)
    }
} 
