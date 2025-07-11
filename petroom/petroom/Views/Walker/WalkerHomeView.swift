import SwiftUI
import Combine

struct DemoJob: Identifiable {
    let id = UUID()
    let petName: String
    let ownerName: String
    let date: Date
    let location: String
    let review: String?
    let rating: Double?
}

struct WalkerHomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAvailability = false
    @State private var showingEarnings = false
    @StateObject private var availabilityViewModel = WalkerAvailabilityViewModel()
    @State private var showingReviews = false
    @StateObject private var earningsViewModel = EarningsViewModel()
    
    // Demo jobs for testing
    let demoJobs: [DemoJob] = [
        DemoJob(
            petName: "Bella",
            ownerName: "Alice",
            date: Date().addingTimeInterval(3600 * 2),
            location: "Central Park",
            review: "Great walk! Bella was happy.",
            rating: 5.0
        ),
        DemoJob(
            petName: "Max",
            ownerName: "Bob",
            date: Date().addingTimeInterval(3600 * 5),
            location: "Riverside",
            review: nil,
            rating: nil
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Today's Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Summary")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            SummaryCard(
                                title: "Jobs",
                                value: "0",
                                systemImage: "calendar",
                                color: .blue
                            )
                            
                            SummaryCard(
                                title: "Earnings",
                                value: "$\(earningsViewModel.totalEarnings)",
                                systemImage: "dollarsign.circle",
                                color: .green
                            )
                            
                            SummaryCard(
                                title: "Rating",
                                value: "0.0",
                                systemImage: "star.fill",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Upcoming Jobs
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Upcoming Jobs")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if demoJobs.isEmpty {
                            Text("No upcoming jobs")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(demoJobs) { job in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(job.petName)
                                            .font(.headline)
                                        Spacer()
                                        Text(job.date, style: .time)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Text("Owner: \(job.ownerName)")
                                        .font(.subheadline)
                                    Text("Location: \(job.location)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    if let review = job.review, let rating = job.rating {
                                        HStack(spacing: 4) {
                                            ForEach(0..<5) { i in
                                                Image(systemName: i < Int(rating) ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.caption)
                                            }
                                            Text("\"\(review)\"")
                                                .font(.caption)
                                                .italic()
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                           /*
                            QuickActionButton(
                                title: "Set Availability",
                                systemImage: "calendar.badge.clock",
                                action: { showingAvailability = true }
                            )
                            
                            QuickActionButton(
                                title: "View Earnings",
                                systemImage: "dollarsign.circle.fill",
                                action: { showingEarnings = true }
                            )
                            */
                            
                            QuickActionButton(
                                title: "View Reviews",
                                systemImage: "star.fill",
                                action: { showingReviews = true }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
            .sheet(isPresented: $showingAvailability) {
                AvailabilityView(viewModel: availabilityViewModel)
            }
            .sheet(isPresented: $showingEarnings) {
                EarningsView(viewModel: earningsViewModel)
            }
            .sheet(isPresented: $showingReviews) {
                ReviewsView()
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ReviewsView: View {
    // Demo reviews
    let reviews: [(review: String, rating: Int, reviewer: String)] = [
        ("Great walk! Bella was happy.", 5, "Alice"),
        ("Max enjoyed his time, thank you!", 4, "Bob"),
        ("Very punctual and friendly.", 5, "Charlie")
    ]
    
    var body: some View {
        NavigationView {
            List(reviews, id: \.review) { item in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { i in
                            Image(systemName: i < item.rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                        Text("- \(item.reviewer)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\"\(item.review)\"")
                        .italic()
                        .font(.body)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Reviews")
        }
    }
} 
