import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Key Metrics
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Metrics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            SummaryCard(
                                title: "Total Users",
                                value: "0",
                                systemImage: "person.2.fill",
                                color: .blue
                            )
                            
                            SummaryCard(
                                title: "Active Bookings",
                                value: "0",
                                systemImage: "calendar",
                                color: .green
                            )
                            
                            SummaryCard(
                                title: "Revenue",
                                value: "$0",
                                systemImage: "dollarsign.circle.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Pending Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Pending Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ActionCard(
                                title: "Walker Approvals",
                                count: 0,
                                systemImage: "person.badge.plus",
                                color: .orange
                            )
                            
                            ActionCard(
                                title: "Disputes",
                                count: 0,
                                systemImage: "exclamationmark.triangle",
                                color: .red
                            )
                            
                            ActionCard(
                                title: "Pending Payouts",
                                count: 0,
                                systemImage: "dollarsign.circle",
                                color: .green
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            QuickActionButton(
                                title: "Manage Users",
                                systemImage: "person.2.fill",
                                action: { /* TODO */ }
                            )
                            
                            QuickActionButton(
                                title: "View Reports",
                                systemImage: "chart.bar.fill",
                                action: { /* TODO */ }
                            )
                            
                            QuickActionButton(
                                title: "Send Message",
                                systemImage: "message.fill",
                                action: { /* TODO */ }
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Admin Dashboard")
        }
    }
}

struct ActionCard: View {
    let title: String
    let count: Int
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text("\(count)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(color)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
} 