//
//  MentalHealthTrackerView.swift
//  MoodSync
//
//  Created by Arihant Marwaha on 18/10/24.
//

import Foundation
import HealthKit
import HealthKitUI
import SwiftUI
import Charts

//2.HealthKit and Sensor Data Integration
//3. Environmental Data Tracking with Raspberry Pi Sensors
//4. IoT Device Control (Philips Hue and Spotify)
//5. Sending Alerts Using Twilio
//6. Personalized Recommendations
//7. Updating MoodSync App UI

/*
struct MentalHealthTrackerApp: View {
    var body: some View {
        TabView {
            MentalHealthTrackerView()
                .tabItem {
                    Label("Tracker", systemImage: "heart.fill")
                }
            
            InsightsView(feedbackMessage: "Your insights will be shown here.", answers: [])
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.blue) // Change tab bar tint color
    }
}
 */




struct MentalHealthTrackerView: View {
    
    @State private var moodLogs: [MoodLog] = [] // Initialize moodLogs
       @State private var moodRating: Int = 3 // Example default value
       @State private var stressLevel: Int = 1 // Example default value
       @State private var showQuestionnaire: Bool = false
       @State private var showMoodInsights: Bool = false
       @State private var showBrowse: Bool = false
       @State private var showLightView: Bool = false

      var body: some View {
          VStack {
              Text("Mental Health Tracker")
                  .font(.largeTitle)
                  .padding(.top)

              Spacer()

              // Mood Selection Slider
              Section(header: Text("How's your mood today?")
                          .font(.headline)
                          .padding(.top)
              ) {
                  MoodSlider(moodRating: $moodRating)
                      .padding()
                      .background(Color.white)
                      .cornerRadius(12)
                      .shadow(radius: 0.5)
                      .padding(.horizontal)
              }

              // Stress Level Picker
              Section(header: Text("Stress Level")
                          .font(.headline)) {
                  StressLevelPicker(stressLevel: $stressLevel)
                      .padding()
                      .background(Color.white)
                      .cornerRadius(12)
                      .shadow(radius: 0.5)
                      .padding(.horizontal)
              }

              // Log Button
              Button(action: {
                  logMood()
              }) {
                  Text("Log Mood")
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(Color.blue)
                      .foregroundColor(.white)
                      .cornerRadius(20)
                      .padding(.horizontal)
              }
              .padding(.bottom, 10)

              // Mood Log List
              List {
                  ForEach(moodLogs) { log in
                      HStack {
                          VStack(alignment: .leading) {
                              Text("Mood: \(log.moodDescription)")
                                  .font(.headline) // Make the mood description bolder
                                  .padding(.bottom, 2) // Add some space below the mood text

                              Text("Stress: \(log.stressDescription)")
                                  .foregroundColor(.gray)
                                  .font(.subheadline) // Use a slightly smaller font for stress
                          }
                          Spacer()
                      }
                      .padding()
                      .background(Color(.white)) // Use a light gray background for better contrast
                      .cornerRadius(12) // Rounded corners for a softer look
                      .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1) // Subtle shadow effect
                      .padding(.vertical, 5) // Maintain vertical padding for spacing
                  }
              }
              .padding(.top)

              // Toolbox at the bottom
              HStack {
                  Spacer()

                  Button(action: {
                      showQuestionnaire.toggle()
                  }) {
                      VStack {
                          Image(systemName: "pencil.circle.fill")
                              .font(.title) // Increase icon size
                          Text("Questionnaire")
                              .font(.footnote)
                      }
                      .padding(.leading,0)
                      .foregroundColor(.blue)
                  }
                  .sheet(isPresented: $showQuestionnaire) {
                      QuestionnaireView()
                  }

                  Spacer()

                  Button(action: {
                      showMoodInsights.toggle() // Show insights when clicked
                  }) {
                      VStack {
                          Image(systemName: "chart.bar.fill")
                              .font(.title) // Increase icon size
                          Text("Insights")
                              .font(.footnote)
                      }
                      .padding(.trailing,0)
                      .foregroundColor(.blue)
                  }
                  .sheet(isPresented: $showMoodInsights) {
                      MoodInsightsView(moodLogs: moodLogs)
                  }

                  Spacer()

                  // Browse Button
                  Button(action: {
                      showBrowse.toggle() // Toggle browse view
                  }) {
                      VStack {
                          Image(systemName: "list.bullet")
                              .font(.title) // Increase icon size
                          Text("Browse")
                              .font(.footnote)
                      }
                      .padding(.trailing,20)
                      .foregroundColor(.blue)
                  }
                  .sheet(isPresented: $showBrowse) {
                      BrowseView(moodLogs: moodLogs) // Pass the moodLogs to BrowseView
                  }
               //lighting button
                  Button(action: {
                      showLightView.toggle()  // Toggle LightView
                  }) {
                      VStack {
                          Image(systemName: "lightbulb.fill")
                              .font(.title)
                          Text("Light info ")
                              .font(.footnote)
                      }
                      .padding(.trailing, 30)
                      .foregroundColor(.blue)
                  }
                  .sheet(isPresented: $showLightView) {
                      LightView(moodRating: moodRating)  // Pass moodRating to LightView
                  }
              }
              .background(Color.white) // Background color for the toolbox
              .cornerRadius(0) // Rounded corners
              .shadow(radius: 0) // Subtle shadow
              .padding(.bottom,-20 ) // Padding for the toolbox
              
              Spacer()
          }
          .navigationTitle("Mental Health Tracker")
          .navigationBarTitleDisplayMode(.inline)
      }

      private func logMood() {
          let newLog = MoodLog(moodRating: moodRating, stressLevel: stressLevel, date: Date())
          moodLogs.insert(newLog, at: 0) // Add the new log at the top of the array
      }
}

struct MentalHealthTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MentalHealthTrackerView()
    }
}

            // Clean and appealing buttons for questionnaire and insights
          /*  VStack(spacing: 10) {
                Button(action: {
                    showQuestionnaire.toggle()
                }) {
                    Text("Take Well-Being Questionnaire")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green) // A softer green for appeal
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .sheet(isPresented: $showQuestionnaire) {
                    QuestionnaireView()
                }

                Button(action: {
                    showMoodInsights.toggle() // Show insights when clicked
                }) {
                    Text("View Mood Insights")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange) // A softer orange for appeal
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .sheet(isPresented: $showMoodInsights) {
                    MoodInsightsView(moodLogs: moodLogs) // Pass the mood logs to the insights view
                }
            }
            .padding(.horizontal) // Padding for the button stack

            Spacer()
        }
        .navigationTitle("Mental Health Tracker")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logMood() {
        let newLog = MoodLog(moodRating: moodRating, stressLevel: stressLevel)
        moodLogs.insert(newLog, at: 0)
    }
}
           */

struct MoodLog: Identifiable {
    let id = UUID()
    let moodRating: Int
    let stressLevel: Int
    let date: Date 
    
    var moodDescription: String {
        switch moodRating {
        case 1: return "Very Sad"
        case 2: return "Sad"
        case 3: return "Neutral"
        case 4: return "Happy"
        case 5: return "Very Happy"
        default: return "Unknown"
        }
    }
    
    var stressDescription: String {
        switch stressLevel {
        case 1: return "Low"
        case 2: return "Moderate"
        case 3: return "High"
        default: return "Unknown"
        }
    }
}

// Mood Slider
struct MoodSlider: View {
    @Binding var moodRating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Mood description with dynamic color
            Text("Mood: \(moodRatingDescription(moodRating))")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(moodColor(for: moodRating)) // Dynamic text color
            
            // Slider
            Slider(value: .init(
                get: { Double(moodRating) },
                set: { newValue in
                    withAnimation(.easeInOut) {
                        moodRating = Int(newValue)
                    }
                }
            ), in: 1...5, step: 1)
            .accentColor(.blue) // Slider color
            .padding(.vertical, 5) // Add some padding around the slider
        }
        .padding() // Padding around the entire VStack
        .background(Color.white) // Background color
        .cornerRadius(15) // Rounded corners for the overall component
        .shadow(radius: 0) // Shadow for overall depth
    }

    private func moodRatingDescription(_ rating: Int) -> String {
        switch rating {
        case 1: return "Very Sad"
        case 2: return "Sad"
        case 3: return "Neutral"
        case 4: return "Happy"
        case 5: return "Very Happy"
        default: return "Unknown"
        }
    }
    
    private func moodColor(for rating: Int) -> Color {
        switch rating {
        case 1: return .red // Very Sad
        case 2: return .orange // Sad
        case 3: return .gray // Neutral
        case 4: return .yellow // Happy
        case 5: return .green // Very Happy
        default: return .black // Unknown
        }
    }
}


// Stress Level Picker
struct StressLevelPicker: View {
    @Binding var stressLevel: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select Your Stress Level")
                .font(.headline)
                .padding(.bottom, 5)
                .padding(.leading, 50)

            Picker("Select your stress level", selection: $stressLevel) {
                Text("Low").tag(1)
                Text("Moderate").tag(2)
                Text("High").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(colorForStressLevel(stressLevel)) // Background color
            .cornerRadius(12) // Rounded corners for the picker
            .shadow(radius: 0) // Shadow for depth
        }
        .padding(.horizontal) // Horizontal padding for the entire VStack
    }

    // Computed property to determine the color based on the stress level
    private func colorForStressLevel(_ level: Int) -> Color {
        switch level {
        case 1:
            return .green // Green for low stress
        case 2:
            return .orange // Orange for moderate stress
        case 3:
            return .red // Red for high stress
        default:
            return .gray // Default color
        }
    }
}



struct SettingsView: View {
    var body: some View {
        Text("Settings View")
            .font(.largeTitle)
    }
}

struct MentalHealthTrackerApp_Previews: PreviewProvider {
    static var previews: some View {
        MentalHealthTrackerView()
    }
}





//questionare view
import SwiftUI
import Charts

import SwiftUI

struct QuestionnaireView: View {
    @State private var answers: [Double] = Array(repeating: 0, count: 10)
    @State private var feedbackMessage = ""
    @State private var navigateToInsights = false
    @State private var moodScore: Double = 0
    @State private var stressScore: Double = 0
    @Environment(\.presentationMode) var presentationMode
    
    

    let questions = [
        "How would you rate your mood today?",
        "How often do you feel anxious?",
        "How often do you feel overwhelmed?",
        "How often do you feel you lack motivation?",
        "How stressed have you felt over the last week?",
        "How well are you sleeping?",
        "How often do you feel happy?",
        "How often do you feel irritable?",
        "How well are you managing stress?",
        "How would you rate your energy levels?"
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Mental Health Questionnaire")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top)

                        ForEach(0..<questions.count, id: \.self) { index in
                            QuestionCard(question: questions[index], answer: $answers[index])
                            
                        }
                    }
                }

                // NavigationLink for insights view
                NavigationLink(destination: InsightsView(feedbackMessage: feedbackMessage, answers: answers), isActive: $navigateToInsights) {
                    EmptyView() // Placeholder for the link
                }
                
                // Submit Button
                Button(action: submitAnswers) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(20)
                }
                .padding(.vertical)
            }
            .padding()
            .navigationTitle("Well-being Questionnaire")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func submitAnswers() {
        feedbackMessage = ""
        moodScore = answers[0]
        stressScore = answers[4]
        
        if moodScore < 5 {
            feedbackMessage += "Your mood seems low. Consider engaging in activities that lift your spirits.\n"
        } else {
            feedbackMessage += "Great job! Your mood is looking good. Keep it up!\n"
        }

        if stressScore > 7 {
            feedbackMessage += "You're experiencing high stress. Try stress management techniques like mindfulness.\n"
        } else {
            feedbackMessage += "Your stress levels are manageable. Keep practicing self-care!\n"
        }

        if answers.contains(1) {
            feedbackMessage += "If you're having thoughts of harm, reach out to a mental health professional immediately.\n"
        }

        if feedbackMessage.isEmpty {
            feedbackMessage = "Overall, you're doing well. Keep up the good work!"
        }

        navigateToInsights = true
    }
}

struct QuestionCard: View {
    var question: String
    @Binding var answer: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(question)
                .font(.headline)

            Slider(value: $answer, in: 1...10, step: 1) {
                Text("Rate")
            }
            .accentColor(sliderColor(for: answer))
            

            Text("Your answer: \(Int(answer))")
                .font(.subheadline)
                .foregroundColor(.gray)

            RoundedRectangle(cornerRadius: 10)
                .frame(height: 2)
                .foregroundColor(sliderColor(for: answer))
                .padding(.bottom)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 0)
    }

    private func sliderColor(for value: Double) -> Color {
        switch value {
        case 1..<4:
            return .red // Low values
        case 4..<7:
            return .yellow // Medium values
        default:
            return .green // High values
        }
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}


//insights of the app
import SwiftUI
import Charts

struct InsightsView: View {
    var feedbackMessage: String
    var answers: [Double]
    

    private var moodAverage: Double {
        calculateAverage(for: Array(answers.prefix(3))) // Assuming the first three are mood-related
    }

    private var stressAverage: Double {
        calculateAverage(for: Array(answers.dropFirst(4).prefix(2))) // Assuming the next two are stress-related
    }

    private func calculateAverage(for values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        return values.reduce(0, +) / Double(values.count)
    }   

    private var insights: String {
        var insightsMessage = ""
        insightsMessage += moodInsights(moodAverage)
        insightsMessage += stressInsights(stressAverage)
        return insightsMessage
    }

    private func moodInsights(_ average: Double) -> String {
        switch average {
        case 8...10:
            return "✅ Great job! Your mood is looking good. Keep it up!\n"
        case 5..<8:
            return "😊 Your mood is decent. Consider engaging in enjoyable activities.\n"
        default:
            return "😞 Your mood could use some improvement. Consider talking to someone.\n"
        }
    }

    private func stressInsights(_ average: Double) -> String {
        switch average {
        case 8...10:
            return "⚠️ High stress levels. Prioritize relaxation and self-care activities.\n"
        case 5..<8:
            return "🆗 Manageable stress levels. Keep monitoring them and take breaks.\n"
        default:
            return "🌟 Great job! Your stress levels are low, which is beneficial!\n"
        }
    }

    private func feedbackForAnswer(_ answer: Double) -> String {
        switch answer {
        case ..<4:
            return "Consider reflecting on this aspect for improvement."
        case 4..<8:
            return "You're in a decent place with this aspect. Keep working on it!"
        default:
            return "You're doing great in this area! Keep it up!"
        }
    }

    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Detailed Insights")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                // Display feedback messages
                ForEach(feedbackMessage.split(separator: "\n").map(String.init), id: \.self) { feedback in
                    HStack(alignment: .top) {
                        let iconName = feedback.contains("Great job") ? "checkmark.circle" : "exclamationmark.triangle"
                        let iconColor: Color = feedback.contains("Great job") ? .green : .yellow

                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                        Text(feedback)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 5)
                    .background(feedback.contains("Great job") ? Color.green.opacity(0.1) : Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }

                // Insights Text
                Text(insights)
                    .font(.body)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.bottom)

                // Modern Line Chart
                Text("Your Mood and Stress Levels Over Time")
                    .font(.headline)
                    .padding(.top, 10)

                Chart {
                    // Chart data based on answers
                    ForEach(0..<answers.count, id: \.self) { index in
                        LineMark(x: .value("Question \(index + 1)", index + 1), y: .value("Score", answers[index]))
                            .foregroundStyle(Color.blue)
                            .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 300)
                .padding(.vertical)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .chartYScale(domain: 0...10)
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .padding(.bottom)

                // Additional Insights section
                Text("Additional Insights")
                    .font(.headline)
                    .padding(.top, 10)

                ForEach(0..<answers.count, id: \.self) { index in
                    let answer = answers[index]
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Question \(index + 1):")
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(answer, specifier: "%.1f")") // Display the answer with one decimal place
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Text(feedbackForAnswer(answer))
                            .font(.body)
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                            .background(Color.blue.opacity(0.1)) // Light blue background for feedback
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Your Mental Health Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView(feedbackMessage: "Great job! Your mood is looking good.\nKeep it up!", answers: [8, 7, 9, 6, 4, 5, 3, 7, 8, 9])
    }
}

struct InsightsTabView: View {
    @State private var answers: [Double] = Array(repeating: 5, count: 10) // Example data

    var body: some View {
        NavigationStack {
            InsightsView(feedbackMessage: generateFeedback(), answers: answers)
                .navigationTitle("Insights")
                .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func generateFeedback() -> String {
        var feedback = ""
        let moodScore = answers[0]
        let stressScore = answers[4]
        
        if moodScore < 5 {
            feedback += "Your mood seems low. Consider engaging in activities that lift your spirits.\n"
        } else {
            feedback += "Great job! Your mood is looking good. Keep it up!\n"
        }
        
        if stressScore > 7 {
            feedback += "You're experiencing high stress. Try stress management techniques.\n"
        } else {
            feedback += "Your stress levels are manageable. Keep practicing self-care!\n"
        }
        
        return feedback
    }
}







