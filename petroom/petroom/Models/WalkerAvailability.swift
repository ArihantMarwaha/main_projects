import Foundation

struct WalkerAvailability: Codable {
    var availableDays: [String] // e.g., ["Monday", "Wednesday"]
    var startTime: Date
    var endTime: Date
} 