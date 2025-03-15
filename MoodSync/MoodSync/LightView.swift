import SwiftUI

// Define the LightView
struct LightView: View {
    @State private var selectedMood: String = "happy" // Default mood
    @State private var moodLightingSettings: [String: [String: Any]] = [
        "happy": ["on": true, "bri": 254, "hue": 8449, "sat": 250, "description": "Bright yellow to uplift your spirits."],
        "sad": ["on": true, "bri": 127, "hue": 46920, "sat": 200, "description": "Soft blue to soothe your emotions."],
        "energetic": ["on": true, "bri": 254, "hue": 25500, "sat": 254, "description": "Bright white to energize your day."],
        "relaxed": ["on": true, "bri": 200, "hue": 50000, "sat": 127, "description": "Warm white to help you unwind."]
    ]
    var moodRating: Int // Passed from MentalHealthTrackerView

    @State private var animateColorChange: Bool = false // State for animation

    var body: some View {
        ZStack {
            // Background Color
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)

            VStack {
                // Current Mood Rating Display
                Text("Current Mood Rating: \(moodRating)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.white) // White background for contrast
                    .cornerRadius(12) // Rounded corners
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Subtle shadow effect
                    .padding(.horizontal)

                // Insights Section with Fade Animation
                VStack(spacing: 20) {
                    if let moodKey = moodKey(for: moodRating) {
                        Text("Insights for Mood: \(moodKey.capitalized)")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.top)

                        // Color Circle with Animation
                        Circle()
                            .fill(colorForMood(moodKey: moodKey))
                            .frame(width: 100, height: 100)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)) // Subtle border for the circle
                            .scaleEffect(animateColorChange ? 1.1 : 1.0) // Animate scale effect
                            .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: animateColorChange) // Loop animation
                            .onAppear {
                                animateColorChange.toggle() // Start animation when the view appears
                            }

                        Text(moodLightingSettings[moodKey]!["description"] as! String)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: 300) // Limit the width for better readability
                    }
                }
                .padding()

                // Button to update lights
                Button(action: {
                    updateLighting(for: moodRating)
                }) {
                    Text("Update Lights")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity) // Make the button stretch
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3) // Add shadow to the button
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Lighting Control")
    }

    // Function to get mood key based on mood rating
    private func moodKey(for mood: Int) -> String? {
        switch mood {
        case 1: return "sad"
        case 2: return "relaxed"
        case 3: return "happy"
        case 4: return "energetic"
        default: return "happy" // Default mood
        }
    }

    // Function to get the color based on the mood key
    private func colorForMood(moodKey: String) -> Color {
        switch moodKey {
        case "happy": return Color.yellow // Bright yellow
        case "sad": return Color.blue // Soft blue
        case "energetic": return Color.white // Bright white
        case "relaxed": return Color.gray // Warm white
        default: return Color.clear // Default clear
        }
    }

    // Function to update lighting based on mood
    private func updateLighting(for mood: Int) {
        guard let moodKey = moodKey(for: mood) else { return }
        guard let settings = moodLightingSettings[moodKey] else { return }

        let bridgeIP = "<bridge_ip_address>" // Replace with your Philips Hue Bridge IP
        let username = "<username>" // Replace with your generated username

        guard let url = URL(string: "http://\(bridgeIP)/api/\(username)/groups/0/action") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: settings)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating lights: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    print("Lighting updated for mood: \(moodKey)")
                } else {
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Failed to update lighting: \(responseBody)")
                    } else {
                        print("Failed with status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
}

// Preview for SwiftUI's design canvas
struct LightView_Previews: PreviewProvider {
    static var previews: some View {
        LightView(moodRating: 3) // Example mood rating
    }
}
