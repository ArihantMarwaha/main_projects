import Foundation

struct ScheduleItem: Identifiable, Codable {
    let id: UUID
    let petName: String
    let ownerName: String
    let date: Date
    let time: String
    let location: String
    let isCompleted: Bool
} 