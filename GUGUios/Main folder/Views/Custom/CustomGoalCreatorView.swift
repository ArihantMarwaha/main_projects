//
//  CustomGoalCreatorView.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI
import SwiftData
import Foundation

struct CustomGoalCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var goalsManager: GoalsManager
    @StateObject private var viewModel = CustomGoalCreatorViewModel()
    @FocusState private var focusedField: Field?
    @State private var isSaving = false
    
    private enum Field: Hashable {
        case title, description, interval
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color for the entire view
                (colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
                    .ignoresSafeArea()
                
                Form {
                    previewSection
                    basicInformationSection
                    appearanceSection
                    targetConfigurationSection
                    remindersSection
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Create New Goal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            isSaving = true
                            Task {
                                await viewModel.saveGoal()
                                await MainActor.run {
                                    isSaving = false
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!viewModel.isFormValid || isSaving)
                        .overlay(
                            isSaving ? ProgressView()
                                .scaleEffect(0.8)
                                .opacity(0.8)
                            : nil
                        )
                    }
                    
                    ToolbarItem(placement: .keyboard) {
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
                .alert("Invalid Goal", isPresented: $viewModel.showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage)
                }
            }
        }
        .task {
            viewModel.updateGoalsManager(goalsManager)
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: viewModel.intervalHours) {
            viewModel.updateInterval()
        }
        .onChange(of: viewModel.intervalMinutes) {
            viewModel.updateInterval()
        }
    }
    
    private var basicInformationSection: some View {
        Section("Goal Information") {
            TextField("Goal Title", text: $viewModel.template.title)
                .focused($focusedField, equals: .title)
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .description
                }
            
            TextField("Description (Optional)", text: $viewModel.template.description, axis: .vertical)
                .focused($focusedField, equals: .description)
                .lineLimit(3...)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .interval
                }
        }
    }
    
    private var targetConfigurationSection: some View {
        Section {
            Stepper {
                HStack {
                    Text("Daily Target")
                    Spacer()
                    Text("\(viewModel.template.targetCount)")
                        .foregroundColor(.secondary)
                }
            } onIncrement: {
                viewModel.incrementTarget()
            } onDecrement: {
                viewModel.decrementTarget()
            }
            
            VStack {
                HStack {
                    Text("Time Interval")
                    Spacer()
                    Text(viewModel.template.intervalHours == 0 ? "No cooldown" : formatInterval(hours: viewModel.template.intervalHours))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Picker("Hours", selection: $viewModel.intervalHours) {
                        Text("No cooldown").tag(0)
                        ForEach(0...23, id: \.self) { hour in
                            Text("\(hour)h").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    
                    Picker("Minutes", selection: $viewModel.intervalMinutes) {
                        ForEach(0..<60, id: \.self) { minute in
                            Text("\(minute)min").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .disabled(viewModel.intervalHours == 0)
                }
                .frame(height: 100)
            }
        } header: {
            Text("Target Configuration")
        } footer: {
            Text(viewModel.template.intervalHours == 0
                 ? "No cooldown between logs"
                 : "Cooldown between logs: \(formatInterval(hours: viewModel.template.intervalHours))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var appearanceSection: some View {
        Section("Appearance") {
            ColorSchemePicker(selection: $viewModel.template.colorScheme)
        }
    }
    
    
    // Helper function to format the interval
    private func formatInterval(hours: Double) -> String {
        if hours < 1 {
            let minutes = Int(hours * 60)
            return "\(minutes)min"
        } else if hours.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(hours))h"
        } else {
            let wholeHours = Int(hours)
            let minutes = Int((hours - Double(wholeHours)) * 60)
            return "\(wholeHours)h \(minutes)min"
        }
    }
    
   
    private var remindersSection: some View {
        Section {
            Toggle("Enable Custom Reminders", isOn: $viewModel.template.hasCustomReminders)
                .onChange(of: viewModel.template.hasCustomReminders) {
                    if !viewModel.template.hasCustomReminders {
                        viewModel.template.reminderTimes.removeAll()
                    }
                }
            
            if viewModel.template.hasCustomReminders {
                ForEach(Array(viewModel.template.reminderTimes.enumerated()), id: \.offset) { index, reminderTime in
                    DatePicker("Reminder \(index + 1)", selection: Binding(
                        get: { viewModel.template.reminderTimes[index] },
                        set: { viewModel.template.reminderTimes[index] = $0 }
                    ), displayedComponents: .hourAndMinute)
                }
                .onDelete(perform: viewModel.deleteReminder)
                
                Button("Add Reminder") {
                    viewModel.addReminder()
                }
                .disabled(viewModel.template.reminderTimes.count >= 5)
            }
        } header: {
            Text("Reminders")
        } footer: {
            if viewModel.template.hasCustomReminders {
                Text("Set specific times to be reminded about this goal. Description will be used as reminder text.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var previewSection: some View {
        Section("Preview") {
            GoalPreviewCard(template: viewModel.template) {
                // Preview tap action if needed
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
    }
}

// Preview
struct CustomGoalCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        // Create temporary ModelContext for preview
        let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let modelContext = container.mainContext
        
        let previewManager = GoalsManager(modelContext: modelContext)
        Group {
            CustomGoalCreatorView()
                .environmentObject(previewManager)
                .previewDisplayName("Light Mode")
            
            CustomGoalCreatorView()
                .environmentObject(previewManager)
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
