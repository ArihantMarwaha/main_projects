import Foundation
import SwiftUI
import Combine

class WalkerAvailabilityViewModel: ObservableObject {
    @Published var availableDays: Set<String> = []
    @Published var startTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @Published var endTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

    private let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let userDefaultsKey = "walkerAvailability"

    init() {
        loadAvailability()
    }

    func loadAvailability() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let saved = try? JSONDecoder().decode(WalkerAvailability.self, from: data) {
            self.availableDays = Set(saved.availableDays)
            self.startTime = saved.startTime
            self.endTime = saved.endTime
        }
    }

    func saveAvailability() {
        let availability = WalkerAvailability(
            availableDays: Array(availableDays),
            startTime: startTime,
            endTime: endTime
        )
        if let data = try? JSONEncoder().encode(availability) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func toggleDay(_ day: String) {
        if availableDays.contains(day) {
            availableDays.remove(day)
        } else {
            availableDays.insert(day)
        }
    }

    func getDaysOfWeek() -> [String] {
        daysOfWeek
    }
} 
