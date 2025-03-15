//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI
import Foundation

struct CustomGoalCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var goalsManager: GoalsManager
    @StateObject private var viewModel: CustomGoalCreatorViewModel
    @FocusState private var focusedField: Field?
    
    init() {
        _viewModel = StateObject(wrappedValue: CustomGoalCreatorViewModel(goalsManager: GoalsManager()))
    }
    
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
                    basicInformationSection
                    targetConfigurationSection
                    appearanceSection
                    previewSection
                }
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle("Create New Goal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                await viewModel.saveGoal()
                                dismiss()
                            }
                        }
                        .disabled(!viewModel.isFormValid)
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
            let newViewModel = CustomGoalCreatorViewModel(goalsManager: goalsManager)
            newViewModel.template = viewModel.template
            viewModel.updateGoalsManager(goalsManager)
        }
        .preferredColorScheme(colorScheme)
        .onChange(of: viewModel.intervalHours) { _ in
            viewModel.updateInterval()
        }
        .onChange(of: viewModel.intervalMinutes) { _ in
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
    
    private var appearanceSection: some View {
        Section("Appearance") {
            ColorSchemePicker(selection: $viewModel.template.colorScheme)
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
        let previewManager = GoalsManager()
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

