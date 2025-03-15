//
//  ContentView.swift
//  MoodSync
//
//  Created by Arihant Marwaha on 18/10/24.
//

import SwiftUI
import Charts
import HealthKit
import HealthKitUI


/*
class HealthDataStore {
    private let healthStore = HKHealthStore()
    
    // Function to request authorization for health data
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        
        healthStore.requestAuthorization(toShare: [], read: [heartRateType, sleepType]) { success, error in
            if success {
                print("HealthKit authorization granted.")
                completion(true)
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
                completion(false)
            }
        }
    }

    // Async function to fetch heart rate data
    func fetchHeartRate() async throws -> Double {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]) { _, result, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sample = result?.first as? HKQuantitySample else {
                    continuation.resume(throwing: NSError(domain: "HealthDataStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "No heart rate data available"]))
                    return
                }
                
                let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                continuation.resume(returning: heartRate)
            }
            healthStore.execute(query)
        }
    }
}
*/

//updating the UI


import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    // Main Mental Health Tracker View
                    MentalHealthTrackerView()
                } else {
                    // Login Form
                    VStack(alignment: .leading, spacing: 16) {
                        // Add the Image Here
                        Image("LogoBlack") // Replace with your image name
                            .resizable()
                            .scaledToFit()
                            .frame(height: 75) // Adjust the height as needed
                            .padding(.top, 30)
                            .padding(.bottom, 0)
                            .padding(.leading,120)
                      
                    
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 0)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, 0)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                        }
                        
                        Button(action: {
                            login()
                        }) {
                            HStack {
                                Spacer()
                                Text(isLoading ? "Logging in..." : "Login")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding()
                            .background(isLoading ? Color.gray : Color.blue)
                            .cornerRadius(20)
                        }
                        .disabled(isLoading) // Disable button while loading
                        .padding(.horizontal, 50)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemGroupedBackground)) // Using a grouped background color
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("MoodSync")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func login() {
        // Reset error message
        errorMessage = ""
        
        // Basic validation
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Username and password cannot be empty."
            return
        }
        
        // Simulate network call
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Simulated authentication (replace this with real logic)
            if username == "Users" && password == "arihant" {
                isLoggedIn = true
            } else {
                errorMessage = "Invalid username or password."
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

