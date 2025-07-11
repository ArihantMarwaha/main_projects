import Foundation

/// Represents a pet in the system
/// Contains all necessary information about a pet for service booking
struct Pet: Identifiable, Codable {
    /// Unique identifier for the pet
    let id: String
    
    /// ID of the pet's owner
    let ownerId: String
    
    /// Pet's name
    var name: String
    
    /// Pet's breed
    var breed: String
    
    /// Pet's age in years
    var age: Int
    
    /// Additional notes about the pet
    var notes: String?
    
    /// URL to pet's photo
    var photoURL: String?
    
    /// Special instructions for pet care
    var specialInstructions: String?
    
    // MARK: - Additional Health and Care Information
    
    /// Pet's weight in pounds/kilograms
    var weight: Double?
    
    /// List of any medical conditions
    var medicalConditions: [String]?
    
    /// Pet's favorite toys
    var favoriteToys: [String]?
    
    /// Pet's feeding schedule
    var feedingSchedule: String?
} 