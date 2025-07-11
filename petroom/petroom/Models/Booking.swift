import Foundation

/// Represents the current status of a booking
enum BookingStatus: String, Codable {
    /// Initial state when booking is created
    case pending
    
    /// Booking has been confirmed by the walker
    case confirmed
    
    /// Service is currently in progress
    case inProgress
    
    /// Service has been completed
    case completed
    
    /// Booking has been cancelled
    case cancelled
}

/// Represents a service booking in the system
struct Booking: Identifiable, Codable {
    /// Unique identifier for the booking
    let id: String
    
    /// ID of the pet owner who made the booking
    let ownerId: String
    
    /// ID of the walker assigned to the booking
    let walkerId: String
    
    /// ID of the pet for which the service is booked
    let petId: String
    
    /// Date and time when the service is scheduled
    let date: Date
    
    /// Duration of the service in minutes
    let duration: Int
    
    /// Type of service requested
    let serviceType: String
    
    /// Current status of the booking
    var status: BookingStatus
    
    /// Total price of the booking
    let price: Double
    
    /// Additional notes for the walker
    var notes: String?
    
    /// Rating given by the owner after service completion
    var rating: Int?
    
    /// Review/feedback provided by the owner
    var review: String?
    
    /// Whether the booking has been paid for
    var isPaid: Bool
    
    /// Payment method used
    var paymentMethod: String?
    
    /// Date when the booking was created
    let createdAt: Date
    
    /// Date when the booking was last updated
    var updatedAt: Date
} 