import Foundation
import Combine

class EarningsViewModel: ObservableObject {
    @Published var earnings: [Double] = [25.0, 30.0, 15.0] // Demo data

    var totalEarnings: Double {
        earnings.reduce(0, +)
    }

    func addEarning(_ amount: Double) {
        earnings.append(amount)
    }

    init() {
        loadEarnings()
    }

    func loadEarnings() {
        // TODO: Replace with actual data fetching logic (from API, database, etc.)
        // For now, use mock data
        let mockEarnings = [
            Earning(id: UUID(), bookingId: UUID(), amount: 25.0, date: Date(), isPaid: true),
            Earning(id: UUID(), bookingId: UUID(), amount: 30.0, date: Date().addingTimeInterval(-86400), isPaid: true)
        ]
        self.earnings = mockEarnings.map { $0.amount }
    }
} 
