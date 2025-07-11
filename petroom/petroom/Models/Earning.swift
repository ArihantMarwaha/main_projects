import Foundation

struct Earning: Identifiable, Codable {
    let id: UUID
    let bookingId: UUID
    let amount: Double
    let date: Date
    let isPaid: Bool
} 