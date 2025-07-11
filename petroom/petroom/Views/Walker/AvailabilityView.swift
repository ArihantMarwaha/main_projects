import SwiftUI

struct AvailabilityView: View {
    @ObservedObject var viewModel: WalkerAvailabilityViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Available Days")) {
                    ForEach(viewModel.getDaysOfWeek(), id: \.self) { day in
                        Button(action: {
                            viewModel.toggleDay(day)
                        }) {
                            HStack {
                                Text(day)
                                Spacer()
                                if viewModel.availableDays.contains(day) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Available Time")) {
                    DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Set Availability")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.saveAvailability()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
} 