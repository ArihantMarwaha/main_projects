import Foundation
import Combine
class ScheduleViewModel: ObservableObject {
    @Published var schedule: [ScheduleItem] = []

    init() {
        loadSchedule()
    }

    func loadSchedule() {
        // TODO: Replace with actual data fetching logic (API, database, etc.)
        // Mock data for now
        self.schedule = [
            ScheduleItem(
                id: UUID(),
                petName: "Bella",
                ownerName: "Alice",
                date: Date(),
                time: "10:00 AM",
                location: "Central Park",
                isCompleted: false
            ),
            ScheduleItem(
                id: UUID(),
                petName: "Max",
                ownerName: "Bob",
                date: Date().addingTimeInterval(3600 * 3),
                time: "1:00 PM",
                location: "Riverside",
                isCompleted: false
            )
        ]
    }
} 
