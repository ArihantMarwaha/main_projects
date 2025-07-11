import SwiftUI

struct BookingHistoryView: View {
    let bookings: [Booking]
    let pets: [Pet]
    let users: [User]
    
    var body: some View {
        NavigationView {
            List(sortedBookings, id: \ .id) { booking in
                BookingCardView(
                    booking: booking,
                    pet: pets.first(where: { $0.id == booking.petId }),
                    walker: users.first(where: { $0.id == booking.walkerId })
                )
                .padding(.vertical, 4)
            }
            .navigationTitle("Booking History")
        }
    }
    
    private var sortedBookings: [Booking] {
        bookings.sorted { $0.date > $1.date }
    }
}

#if DEBUG
struct BookingHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        BookingHistoryView(bookings: [], pets: [], users: [])
    }
}
#endif 