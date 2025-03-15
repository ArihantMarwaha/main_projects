import SwiftUI

struct PetSystemPreview: View {
    @StateObject private var testManager = TestPetActivityManager()
    @StateObject private var goalsManager = GoalsManager()
    @State private var selectedTimeScale = 60 // Default to 1min/sec
    @State private var isSimulationActive = false
    
    let timeScales = [
        1: "Normal",
        60: "1min/sec",
        300: "5min/sec",
        900: "15min/sec",
        3600: "1hr/sec"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Time Control Panel
                    VStack(spacing: 12) {
                        Text("Time Control")
                            .font(.headline)
                        
                        Picker("Time Scale", selection: $selectedTimeScale) {
                            ForEach(Array(timeScales.keys.sorted()), id: \.self) { scale in
                                Text(timeScales[scale] ?? "")
                                    .tag(scale)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        Toggle("Accelerated Time", isOn: $isSimulationActive)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Stats Display
                    VStack(spacing: 8) {
                        Text("Pet Stats")
                            .font(.headline)
                        
                        Group {
                            statRow("Energy", value: testManager.petData.energy, color: .green)
                            statRow("Hydration", value: testManager.petData.hydration, color: .blue)
                            statRow("Satiation", value: testManager.petData.satisfaction, color: .orange)
                        }
                        
                        HStack {
                            Text("Current State:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(testManager.petData.state.rawValue) \(testManager.petData.mood)")
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Quick Actions
                    VStack(spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            actionButton("Water", action: { testManager.updateProgress(for: "Water Intake") })
                            actionButton("Meal", action: { testManager.updateProgress(for: "Meals & Snacks") })
                            actionButton("Break", action: { testManager.updateProgress(for: "Take Breaks") })
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Pet View
                    PetView(petManager: testManager)
                        .environmentObject(goalsManager)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Pet Preview")
            .onChange(of: selectedTimeScale) { newValue in
                if isSimulationActive {
                    testManager.setTimeMultiplier(Double(newValue))
                }
            }
            .onChange(of: isSimulationActive) { newValue in
                if newValue {
                    testManager.startSimulation(multiplier: Double(selectedTimeScale))
                } else {
                    testManager.pauseSimulation()
                }
            }
            .onDisappear {
                testManager.pauseSimulation()
            }
        }
    }
    
    private func statRow(_ label: String, value: Int, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text("\(value)%")
                .foregroundColor(color)
                .bold()
        }
    }
    
    private func actionButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .frame(minWidth: 80)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
}

#Preview {
    PetSystemPreview()
} 
