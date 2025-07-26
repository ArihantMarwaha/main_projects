import SwiftUI

struct DailySummaryView: View {
    @ObservedObject var goalsManager: GoalsManager
    @State private var refreshID = UUID()
    
    private var completionPercentage: Double {
        let totalGoals = goalsManager.goals.count
        guard totalGoals > 0 else { return 0 }
        
        let completedGoals = goalsManager.trackers.values.filter { tracker in
            tracker.getProgress() >= 1.0
        }.count
        
        return Double(completedGoals) / Double(totalGoals) * 100
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Today's Progress")
                        .font(.headline)
                    Text("\(Int(completionPercentage))% Complete")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                CircularProgressView(
                    progress: completionPercentage / 100,
                    colorScheme: .blue  // Using blue as default for overall progress
                )
                .frame(width: 70, height: 60)
            }
            
            HStack {
                StatCard(
                    title: "Active Goals",
                    value: "\(goalsManager.goals.count)",
                    icon: "target",
                    color: .blue
                )
            
                
                StatCard(
                    title: "Completed",
                    value: "\(goalsManager.trackers.values.filter { $0.getProgress() >= 1.0 }.count)",
                    icon: "checkmark.circle",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .id(refreshID) // Force refresh when needed
        .onReceive(NotificationCenter.default.publisher(for: .goalProgressUpdated)) { _ in
            withAnimation {
                refreshID = UUID() // Force view update
            }
        }
    }
}


// Preview
struct DailySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewManager = GoalsManager()

        return Group {
            DailySummaryView(goalsManager: previewManager)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Light Mode")
            
            DailySummaryView(goalsManager: previewManager)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

