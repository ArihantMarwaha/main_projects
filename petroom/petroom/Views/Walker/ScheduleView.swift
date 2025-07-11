import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.schedule) { item in
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.petName)
                            .font(.headline)
                        Text("Owner: \(item.ownerName)")
                            .font(.subheadline)
                        Text("\(item.date, style: .date) at \(item.time)")
                            .font(.caption)
                        Text("Location: \(item.location)")
                            .font(.caption2)
                    }
                    Spacer()
                    if item.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("My Schedule")
        }
    }
} 