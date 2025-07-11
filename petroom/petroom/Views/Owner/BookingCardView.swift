import SwiftUI
import Foundation

struct BookingCardView: View {
    let booking: Booking
    let pet: Pet?
    let walker: User?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(pet?.name ?? "Unknown Pet")
                    .font(.headline)
                Spacer()
                Text(booking.status.rawValue.capitalized)
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
            Text("Price: $\(String(format: "%.2f", booking.price))")
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
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
        case .pending: return .orange
        case .confirmed: return .blue
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

// Preview
#if DEBUG
struct BookingCardView_Previews: PreviewProvider {
    static var previews: some View {
        BookingCardView(
            booking: Booking(
                id: "1",
                ownerId: "owner1",
                walkerId: "walker1",
                petId: "pet1",
                date: Date(),
                duration: 60,
                serviceType: "Dog Walking",
                status: .confirmed,
                price: 25.0,
                notes: "",
                isPaid: true,
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