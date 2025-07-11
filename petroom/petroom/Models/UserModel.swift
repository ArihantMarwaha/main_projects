import Foundation
import SwiftData

@Model
final class UserModel {
    @Attribute(.unique) var email: String
    var id: String
    var name: String
    var address: String
    var phoneNumber: String?
    var userType: String // "owner", "walker", or "admin"
    var profileImageURL: String?
    var rating: Double?
    var numberOfRatings: Int
    var bio: String?
    var hourlyRate: Double?
    // For simplicity, services, documents, and availability are omitted for now
    // You can add them as relationships if needed

    init(id: String = UUID().uuidString,
         email: String,
         name: String,
         address: String,
         phoneNumber: String? = nil,
         userType: String,
         profileImageURL: String? = nil,
         rating: Double? = nil,
         numberOfRatings: Int = 0,
         bio: String? = nil,
         hourlyRate: Double? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.userType = userType
        self.profileImageURL = profileImageURL
        self.rating = rating
        self.numberOfRatings = numberOfRatings
        self.bio = bio
        self.hourlyRate = hourlyRate
    }
} 