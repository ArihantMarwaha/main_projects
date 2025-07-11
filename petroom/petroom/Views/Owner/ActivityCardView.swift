import SwiftUI
import Foundation

struct ActivityCardView: View {
    let booking: Booking
    let pet: Pet?
    let walker: User?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pet?.name ?? "Unknown Pet")
                    .font(.headline)
                Spacer()
                Text(activityText(for: booking.status))
                    .font(.subheadline)
                    .foregroundColor(color(for: booking.status))
            }
            Text(booking.serviceType)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let walker = walker {
                Text("Walker: \(walker.name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text("Date: \(formattedDate(booking.date))")
                .font(.caption)
            if let review = booking.review, !review.isEmpty {
                Text("Review: \(review)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func color(for status: BookingStatus) -> Color {
        switch status {
        case .completed: return .green
        case .cancelled: return .red
        default: return .gray
        }
    }
    
    private func activityText(for status: BookingStatus) -> String {
        switch status {
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        default: return "Activity"
        }
    }
}

// Preview
#if DEBUG
struct ActivityCardView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityCardView(
            booking: Booking(
                id: "1",
                ownerId: "owner1",
                walkerId: "walker1",
                petId: "pet1",
                date: Date(),
                duration: 60,
                serviceType: "Dog Walking",
                status: .completed,
                price: 25.0,
                notes: "",
                rating: 5,
                review: "Great service!",
                isPaid: true,
                paymentMethod: "Credit Card",
                createdAt: Date(),
                updatedAt: Date()
            ),
            pet: Pet(id: "pet1", ownerId: "owner1", name: "Buddy", breed: "Labrador", age: 3, notes: nil, photoURL: nil, specialInstructions: nil, weight: nil, medicalConditions: nil, favoriteToys: nil, feedingSchedule: nil),
            walker: User(id: "walker1", email: "walker@example.com", phoneNumber: nil, userType: .walker, name: "Jane Walker", address: "123 St", profileImageURL: nil, rating: nil, numberOfRatings: 0, bio: nil, services: nil, hourlyRate: nil, documents: nil, availability: nil)
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif 