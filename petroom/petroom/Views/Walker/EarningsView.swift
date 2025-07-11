import SwiftUI

struct EarningsView: View {
    @ObservedObject var viewModel: EarningsViewModel
    @State private var newAmount: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Modern Card for Total Earnings
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Earnings")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("$\(viewModel.totalEarnings, specifier: "%.2f")")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "dollarsign.circle.fill")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
            }
            .frame(height: 110)
            .padding(.horizontal)

            // Earnings List - Modern Card Style
            VStack(alignment: .leading, spacing: 0) {
                Text("Earnings History")
                    .font(.headline)
                    .padding(.bottom, 8)
                    .padding(.leading, 8)
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.earnings.enumerated()), id: \.offset) { index, earning in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Earning \(index + 1)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("$\(earning, specifier: "%.2f")")
                                        .font(.headline)
                                }
                                Spacer()
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemGray6))
                                    .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
            .padding(.horizontal)

            // Add Earning - Modern Card Style
            VStack(alignment: .leading, spacing: 16) {
                Text("Add Earning")
                    .font(.headline)
                    .padding(.bottom, 2)
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        TextField("Enter amount", text: $newAmount)
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .font(.body)
                    }
                    .frame(height: 44)

                    Button(action: {
                        if let amount = Double(newAmount), amount > 0 {
                            viewModel.addEarning(amount)
                            newAmount = ""
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.blue]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .shadow(color: Color.green.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(newAmount.isEmpty || Double(newAmount) == nil)
                    .opacity((newAmount.isEmpty || Double(newAmount) == nil) ? 0.5 : 1.0)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Earnings")
                    .font(.headline)
            }
        }
    }
}

struct EarningsViewContainer: View {
    @StateObject var viewModel = EarningsViewModel()
    var body: some View {
        NavigationView {
            EarningsView(viewModel: viewModel)
        }
    }
}

struct EarningsView_Previews: PreviewProvider {
    static var previews: some View {
        EarningsViewContainer()
    }
} 
