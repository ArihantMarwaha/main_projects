import Foundation

/// Represents the type of user in the system
/// - owner: Pet owner who can book services
/// - walker: Service provider who can offer walking/training services
/// - admin: System administrator with oversight capabilities
enum UserType: String, Codable {
    case owner
    case walker
    case admin
}

/// Core user model representing all user types in the system
/// Contains common fields for all users and type-specific fields for walkers
struct User: Identifiable, Codable {
    /// Unique identifier for the user
    let id: String
    
    /// User's email address (used for authentication)
    var email: String
    
    /// Optional phone number for contact
    var phoneNumber: String?
    
    /// Type of user (owner, walker, or admin)
    var userType: UserType
    
    /// User's full name
    var name: String
    
    /// User's physical address
    var address: String
    
    /// URL to user's profile picture
    var profileImageURL: String?
    
    /// Total rating points accumulated
    var rating: Double?
    
    /// Number of ratings received
    var numberOfRatings: Int
    
    // MARK: - Walker Specific Fields
    
    /// Walker's professional biography
    var bio: String?
    
    /// List of services offered by the walker
    var services: [Service]?
    
    /// Walker's hourly rate for services
    var hourlyRate: Double?
    
    /// Walker's verification documents
    var documents: [Document]?
    
    /// Walker's available time slots
    var availability: [Availability]?
    
    /// Computed property that calculates the average rating
    /// Returns 0 if no ratings exist
    var averageRating: Double {
        guard let rating = rating, numberOfRatings > 0 else { return 0 }
        return rating / Double(numberOfRatings)
    }
}

/// Represents a verification document uploaded by a walker
struct Document: Identifiable, Codable {
    /// Unique identifier for the document
    let id: String
    
    /// Type of document (ID, certification, etc.)
    let type: String
    
    /// URL to the stored document
    let url: String
    
    /// Whether the document has been verified by admin
    let verified: Bool
}

/// Represents a service offered by a walker
struct Service: Identifiable, Codable {
    /// Unique identifier for the service
    let id: String
    
    /// Name of the service
    let name: String
    
    /// Detailed description of the service
    let description: String
    
    /// Price of the service
    let price: Double
}

/// Represents a time slot when a walker is available
struct Availability: Identifiable, Codable {
    /// Unique identifier for the availability slot
    let id: String
    
    /// Day of the week (1-7 for Monday-Sunday)
    let dayOfWeek: Int
    
    /// Start time of availability
    let startTime: Date
    
    /// End time of availability
    let endTime: Date
} 