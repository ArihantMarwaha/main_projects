import SwiftUI

struct PlaceholderPetImage: View {
    var body: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .cornerRadius(40)
                .shadow(color: Color(.systemGray4), radius: 3, x: 0, y: 2)
            
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundColor(.blue.opacity(0.7))
        }
        .frame(height: 300)
        .padding(.horizontal, 28)
    }
} 
