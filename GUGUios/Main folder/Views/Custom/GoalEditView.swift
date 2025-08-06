//
//  GoalEditView.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI

struct GoalEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var goalsManager: GoalsManager
    @StateObject private var viewModel: GoalEditViewModel
    @State private var showingDeleteConfirmation = false
    @State private var shouldResetProgress = false
    
    init(goal: Goal) {
        _viewModel = StateObject(wrappedValue: GoalEditViewModel(goal: goal))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                (colorScheme == .dark ? Color.black : Color(.systemGroupedBackground))
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Goal Title", text: $viewModel.title)
                            .textInputAutocapitalization(.words)
                        
                        TextField("Description", text: $viewModel.description, axis: .vertical)
                            .lineLimit(3...)
                    } header: {
                        Text("Basic Information")
                    }
                    
                    Section {
                        Stepper {
                            HStack {
                                Text("Daily Target")
                                Spacer()
                                Text("\(viewModel.targetCount)")
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
                                Text(viewModel.intervalHours == 0 ? "No cooldown" : formatInterval(hours: viewModel.intervalHours))
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
                    }
                    
                    Section {
                        ColorSchemePicker(selection: $viewModel.colorScheme)
                    } header: {
                        Text("Appearance")
                    }
                    
                    Section {
                        Toggle("Enable Custom Reminders", isOn: $viewModel.hasCustomReminders)
                            .onChange(of: viewModel.hasCustomReminders) {
                                if !viewModel.hasCustomReminders {
                                    viewModel.reminderTimes.removeAll()
                                }
                            }
                        
                        if viewModel.hasCustomReminders {
                            ForEach(Array(viewModel.reminderTimes.enumerated()), id: \.offset) { index, reminderTime in
                                DatePicker("Reminder \(index + 1)", selection: Binding(
                                    get: { viewModel.reminderTimes[index] },
                                    set: { viewModel.reminderTimes[index] = $0 }
                                ), displayedComponents: .hourAndMinute)
                            }
                            .onDelete(perform: viewModel.deleteReminder)
                            
                            Button("Add Reminder") {
                                viewModel.addReminder()
                            }
                            .disabled(viewModel.reminderTimes.count >= 5)
                        }
                    } header: {
                        Text("Reminders")
                    } footer: {
                        if viewModel.hasCustomReminders {
                            Text("Set specific times to be reminded about this goal. Description will be used as reminder text.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Section {
                        Toggle("Reset Progress", isOn: $shouldResetProgress)
                    } header: {
                        Text("Progress")
                    } footer: {
                        Text("Turn on to reset current progress. Leave off to keep existing progress.")
                    }
                    
                    if !viewModel.goal.isDefault {
                        Section {
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Goal")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveChanges(using: goalsManager, resetProgress: shouldResetProgress)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Delete Goal", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    goalsManager.deleteGoal(viewModel.goal)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this goal? This action cannot be undone.")
            }
        }
    }
    
    private func formatInterval(hours: Int) -> String {
        if hours == 0 {
            return "\(viewModel.intervalMinutes)min"
        } else if viewModel.intervalMinutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(viewModel.intervalMinutes)min"
        }
    }
}
