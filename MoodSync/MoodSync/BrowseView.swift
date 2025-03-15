import SwiftUI
import Charts


// BrowseView to navigate through the steps
struct BrowseView: View {
    var moodLogs: [MoodLog] // Accepting moodLogs as a parameter

    var body: some View {
        NavigationView {
            List {
                // Mood Tracker Setup
                NavigationLink(destination: Step1View()) {
                    HStack {
                        Image(systemName: "chart.bar.fill") // SF Symbol for Mood Tracker
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.blue)

                        Text("Mood Tracker Setup")
                            .font(.headline) // Customize font style
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4) // Space between logo and text
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Mood Insights
                NavigationLink(destination: Step2View()) {
                    HStack {
                        Image(systemName: "chart.pie.fill") // Updated SF Symbol for Mood Insights
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.green)

                        Text("Mood Insights")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Stress Management Techniques
                NavigationLink(destination: Step3View()) {
                    HStack {
                        Image(systemName: "brain.head.profile") // SF Symbol for Stress Management Techniques
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.orange)

                        Text("Stress Management Techniques")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Activity Tracking
                NavigationLink(destination: Step4View()) {
                    HStack {
                        Image(systemName: "figure.walk") // SF Symbol for Activity Tracking
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.purple)

                        Text("Activity Tracking")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Daily Reflections
                NavigationLink(destination: Step5View()) {
                    HStack {
                        Image(systemName: "text.bubble") // SF Symbol for Daily Reflections
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.red)

                        Text("Daily Reflections")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Weekly Insights
                NavigationLink(destination: Step7View()) {
                    HStack {
                        Image(systemName: "calendar") // SF Symbol for Weekly Insights
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.yellow)

                        Text("Weekly Insights")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Stress and Mood Correlation
                NavigationLink(destination: Step8View()) {
                    HStack {
                        Image(systemName: "arrow.right.arrow.left") // SF Symbol for Stress and Mood Correlation
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.pink)

                        Text("Stress and Mood Correlation")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Mental Health Resources
                NavigationLink(destination: Step9View()) {
                    HStack {
                        Image(systemName: "book") // SF Symbol for Mental Health Resources
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.cyan)

                        Text("Mental Health Resources")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Stress Management
                NavigationLink(destination: Step10View()) {
                    HStack {
                        Image(systemName: "hand.raised.fill") // SF Symbol for Stress Management
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.brown)

                        Text("Stress Management")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Tips and Suggestions
                NavigationLink(destination: Step11View()) {
                    HStack {
                        Image(systemName: "lightbulb") // SF Symbol for Tips and Suggestions
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.gray)

                        Text("Tips and Suggestions")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }

                // Self-Care Suggestions
                NavigationLink(destination: Step12View()) {
                    HStack {
                        Image(systemName: "heart") // SF Symbol for Self-Care Suggestions
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24) // Decreased icon size
                            .foregroundColor(.mint)

                        Text("Self-Care Suggestions")
                            .font(.headline)
                            .font(.system(size: 16)) // Decreased font size
                            .padding(.leading, 4)
                    }
                    .padding(8) // Decreased padding for the entire row
                }
            }
            .navigationTitle("Browse Features")
            .listStyle(PlainListStyle()) // Optional: Use plain style for cleaner look
        }
    }


}

// Preview for BrowseView
struct BrowseView_Previews: PreviewProvider {
    static var previews: some View {
        BrowseView(moodLogs: [
            MoodLog(moodRating: 5, stressLevel: 1, date: Date()),
            MoodLog(moodRating: 3, stressLevel: 2, date: Date()),
            MoodLog(moodRating: 2, stressLevel: 3, date: Date())
        ])
    }
}

// Mood Tracker Setup (Step 1)

// Preview for Step 1
struct Step1View: View {
    
            @State private var selectedLoggingMethod: String = "Manual"
            @State private var customMoodLevels: [String] = ["Happy", "Sad", "Energetic"]
            @State private var newMoodLevel: String = ""

            var body: some View {
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Description
                    Text("Mood Tracker Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Set up your mood tracker by choosing how you want to log your moods and defining custom mood levels.")
                        .font(.body)
                        .padding(.bottom)

                    // Logging Method Selection
                    Text("Select Logging Method:")
                        .font(.headline)
                    
                    Picker("Logging Method", selection: $selectedLoggingMethod) {
                        Text("Manual").tag("Manual")
                        Text("Automated").tag("Automated")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)

                    // Custom Mood Levels Section
                    Text("Define Custom Mood Levels:")
                        .font(.headline)

                    // List of Custom Mood Levels
                    ForEach(customMoodLevels, id: \.self) { mood in
                        Text(mood)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Input Field to Add New Mood Level
                    HStack {
                        TextField("Add a new mood level", text: $newMoodLevel)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button(action: {
                            addNewMoodLevel()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                        }
                        .disabled(newMoodLevel.isEmpty) // Disable button if the text field is empty
                    }
                    .padding(.bottom)

                    Spacer()

                    // Save Button
                    Button(action: {
                        // Action for saving the setup
                        saveMoodTrackerSetup()
                    }) {
                        Text("Save Setup")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom)
                }
                .padding()
                .navigationTitle("Step 1: Mood Tracker")
                .navigationBarTitleDisplayMode(.inline)
            }

            // Function to add a new mood level
            private func addNewMoodLevel() {
                guard !newMoodLevel.isEmpty else { return }
                customMoodLevels.append(newMoodLevel)
                newMoodLevel = "" // Clear the input field
            }

            // Function to save the setup (can be connected to further steps or storage)
            private func saveMoodTrackerSetup() {
                // This is where you would handle the setup logic, such as saving preferences
                print("Logging Method: \(selectedLoggingMethod)")
                print("Custom Mood Levels: \(customMoodLevels)")
            }
        }

        // Preview for Step 1
        struct Step1View_Previews: PreviewProvider {
            static var previews: some View {
                Step1View()
            }
        }

// Mood Insights (Step 2)

// Preview for Step 2

struct Step2View: View {
    @State private var moodData: [MoodEntry] = [
        MoodEntry(date: Date().addingTimeInterval(-86400 * 5), mood: "Happy"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 4), mood: "Sad"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 3), mood: "Energetic"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 2), mood: "Relaxed"),
        MoodEntry(date: Date().addingTimeInterval(-86400 * 1), mood: "Focused")
    ]
    @State private var moodSuggestions: [String] = [
        "Try some deep breathing exercises to stay calm.",
        "Take a walk outside for a fresh perspective.",
        "Listen to your favorite music to uplift your mood.",
        "Reflect on positive moments from the past week."
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Mood Insights")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Get detailed insights about your mood trends and personalized suggestions for improving your well-being.")
                .font(.body)
                .padding(.bottom)

            // Mood Trends Chart
            Text("Mood Trends:")
                .font(.headline)
            
            // Placeholder for the chart (you can integrate with a real charting library like Charts)
            MoodTrendsChart(moodData: moodData)
                .frame(height: 200)
                .padding(.bottom)
            
            // Recent Moods List
            Text("Recent Mood Entries:")
                .font(.headline)
            
            List(moodData, id: \.id) { entry in
                HStack {
                    Text(entry.mood)
                        .font(.body)
                    Spacer()
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxHeight: 150)
            .padding(.bottom)

            // Suggestions Section
            Text("Suggestions for Improving Your Mood:")
                .font(.headline)
            
            ForEach(moodSuggestions, id: \.self) { suggestion in
                Text("• \(suggestion)")
                    .font(.body)
                    .padding(.vertical, 2)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Step 2: Mood Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// A simple model for a mood entry
struct MoodEntry: Identifiable {
    let id = UUID()
    let date: Date
    let mood: String
}

// Placeholder view for a chart (integrate a real charting library for better visualization)
struct MoodTrendsChart: View {
    let moodData: [MoodEntry]

    var body: some View {
        GeometryReader { geometry in
            // This is a placeholder for a real chart, using colored bars to represent mood entries.
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(moodData) { entry in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(colorForMood(entry.mood))
                        .frame(width: (geometry.size.width / CGFloat(moodData.count)) - 4, height: CGFloat.random(in: 50...150))
                        .overlay(
                            Text(entry.mood.prefix(1)) // Show the first letter of the mood
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(4),
                            alignment: .bottom
                        )
                }
            }
        }
    }
    
    // Function to map moods to colors for the chart
    private func colorForMood(_ mood: String) -> Color {
        switch mood {
        case "Happy":
            return .yellow
        case "Sad":
            return .blue
        case "Energetic":
            return .red
        case "Relaxed":
            return .green
        case "Focused":
            return .purple
        default:
            return .gray
        }
    }
}

// Preview for Step 2
struct Step2View_Previews: PreviewProvider {
    static var previews: some View {
        Step2View()
    }
}


// Stress Management Techniques (Step 3)


// Preview for Step 3

struct Step3View: View {
    @State private var techniques: [StressTechnique] = [
        StressTechnique(name: "Deep Breathing", description: "Focus on your breath. Inhale slowly through your nose for 4 seconds, hold for 4 seconds, then exhale through your mouth for 4 seconds. Repeat this cycle 5 times."),
        StressTechnique(name: "Progressive Muscle Relaxation", description: "Tense each muscle group for 5 seconds, then release. Start from your toes and work your way up to your head."),
        StressTechnique(name: "Guided Visualization", description: "Close your eyes and imagine a peaceful place. Focus on the details: the sounds, colors, and feelings. Stay in this visualization for a few minutes."),
        StressTechnique(name: "Mindful Walking", description: "Take a slow walk outside, focusing on each step. Pay attention to how your body moves and the environment around you."),
        StressTechnique(name: "Gratitude Journaling", description: "Write down three things you are grateful for each day. This can help shift your focus to positive aspects of your life.")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Stress Management Techniques")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Explore these techniques to help you manage stress more effectively.")
                .font(.body)
                .padding(.bottom)
            
            // List of Stress Management Techniques
            List(techniques) { technique in
                NavigationLink(destination: TechniqueDetailView(technique: technique)) {
                    HStack {
                        Text(technique.name)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
            .frame(maxHeight: 300)

            Spacer()
        }
        .padding()
        .navigationTitle("Step 3: Stress Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Model for Stress Management Techniques
struct StressTechnique: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

// Detail view for each technique
struct TechniqueDetailView: View {
    let technique: StressTechnique

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(technique.name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text(technique.description)
                .font(.body)
                .padding(.bottom)
            
            Spacer()

            Button(action: {
                // Start guided practice (e.g., play audio or timer for the exercise)
                startGuidedPractice()
            }) {
                Text("Start Practice")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .padding()
        .navigationTitle(technique.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    // Placeholder function for starting guided practice
    private func startGuidedPractice() {
        print("Starting practice for: \(technique.name)")
        // Here, you could integrate a timer or audio guidance for each exercise.
    }
}

// Preview for Step 3
struct Step3View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step3View()
        }
    }
}

// Activity Tracking (Step 4)

// Preview for Step 4

struct Step4View: View {
    @State private var activities: [Activity] = [
        Activity(name: "Morning Walk", moodImpact: "Positive", stressImpact: "Reduced"),
        Activity(name: "Work Meeting", moodImpact: "Neutral", stressImpact: "Increased"),
        Activity(name: "Yoga Session", moodImpact: "Positive", stressImpact: "Reduced"),
        Activity(name: "Screen Time", moodImpact: "Negative", stressImpact: "Increased"),
        Activity(name: "Family Dinner", moodImpact: "Positive", stressImpact: "Neutral")
    ]
    
    @State private var selectedActivity: Activity?
    @State private var showActivityDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Activity Tracking")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Track your daily activities and see their impact on your mood and stress levels over time.")
                .font(.body)
                .padding(.bottom)
            
            // Log Activity Button
            Button(action: {
                // Navigate to a new view to log an activity
                showActivityDetail.toggle()
            }) {
                Text("Log a New Activity")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.bottom)
            .sheet(isPresented: $showActivityDetail) {
                LogActivityView { newActivity in
                    activities.append(newActivity)
                }
            }

            // List of Logged Activities
            Text("Recent Activities:")
                .font(.headline)
            
            List(activities) { activity in
                VStack(alignment: .leading) {
                    Text(activity.name)
                        .font(.headline)
                    HStack {
                        Text("Mood Impact: \(activity.moodImpact)")
                            .font(.subheadline)
                        Spacer()
                        Text("Stress Impact: \(activity.stressImpact)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 300)
            .listStyle(PlainListStyle())

            Spacer()
        }
        .padding()
        .navigationTitle("Step 4: Activity Tracking")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Model for an Activity
struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let moodImpact: String
    let stressImpact: String
}

// View for logging a new activity
struct LogActivityView: View {
    @State private var activityName: String = ""
    @State private var moodImpact: String = "Positive"
    @State private var stressImpact: String = "Reduced"
    let onSave: (Activity) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Activity Name", text: $activityName)
                    
                    Picker("Mood Impact", selection: $moodImpact) {
                        Text("Positive").tag("Positive")
                        Text("Neutral").tag("Neutral")
                        Text("Negative").tag("Negative")
                    }
                    
                    Picker("Stress Impact", selection: $stressImpact) {
                        Text("Reduced").tag("Reduced")
                        Text("Neutral").tag("Neutral")
                        Text("Increased").tag("Increased")
                    }
                }
                
                Button(action: {
                    let newActivity = Activity(name: activityName, moodImpact: moodImpact, stressImpact: stressImpact)
                    onSave(newActivity)
                }) {
                    Text("Save Activity")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(activityName.isEmpty)
            }
            .navigationTitle("Log Activity")
            .navigationBarItems(trailing: Button("Cancel") {
                // Close the view
                onSave(Activity(name: "", moodImpact: "", stressImpact: ""))
            })
        }
    }
}

// Preview for Step 4
struct Step4View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step4View()
        }
    }
}

// Daily Reflections (Step 5)

// Preview for Step 5

struct Step5View: View {
    @State private var reflectionText: String = ""
    @State private var moodRating: Double = 3.0 // Change to Double
    @State private var showSavedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Daily Reflections")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Take a moment to reflect on your day and your mood trends.")
                .font(.body)
                .padding(.bottom)
            
            // Mood Rating Slider
            Text("How would you rate your overall mood today?")
                .font(.headline)
            Slider(value: $moodRating, in: 1...5, step: 1) {
                Text("Mood Rating")
            }
            .padding(.vertical)
            HStack {
                Text("Very Low")
                Spacer()
                Text("Very High")
            }
            .font(.caption)
            
            // Reflection Text Area
            Text("Write your reflection:")
                .font(.headline)
            
            TextEditor(text: $reflectionText)
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(.bottom)
            
            // Save Reflection Button
            Button(action: {
                saveReflection()
            }) {
                Text("Save Reflection")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showSavedAlert) {
                Alert(title: Text("Reflection Saved"), message: Text("Your reflection has been saved successfully."), dismissButton: .default(Text("OK")))
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Step 5: Daily Reflections")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Function to save the reflection (placeholder functionality)
    private func saveReflection() {
        // Here, you can add logic to save the reflection to a database or locally.
        showSavedAlert = true
        print("Saved reflection: \(reflectionText) with mood rating: \(Int(moodRating))") // Convert to Int for logging
    }
}

// Preview for Step 5

import SwiftUI
import Charts // Ensure you're using a compatible charting library

// Model for Mood Data


/*
struct MoodEntry: Identifiable {
    let id = UUID() // Unique identifier
    let date: String // Date as String (you can change this to Date if necessary)
    let mood: Double // Mood rating as Double
}

struct Step6View: View {
    @State private var selectedComparisonPeriod: String = "Weekly"
    @State private var moodData: [MoodEntry] = [
        MoodEntry(date: "Oct 1", mood: 3.0),
        MoodEntry(date: "Oct 2", mood: 4.0),
        MoodEntry(date: "Oct 3", mood: 2.0),
        MoodEntry(date: "Oct 4", mood: 5.0),
        MoodEntry(date: "Oct 5", mood: 3.0)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Mood Comparisons")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Compare your current mood trends with past data to gain insights into your emotional health.")
                .font(.body)
                .padding(.bottom)

            // Period Selection Picker
            Picker("Comparison Period", selection: $selectedComparisonPeriod) {
                Text("Weekly").tag("Weekly")
                Text("Monthly").tag("Monthly")
                Text("Yearly").tag("Yearly")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.bottom)

            // Mood Trend Chart
            Chart {
                ForEach(moodData) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Mood Rating", entry.mood) // Correctly using entry.mood
                    )
                    .symbol(Circle())
                    .foregroundStyle(Color.blue)
                }
            }
            .frame(height: 200)
            .padding(.bottom)

            // Mood Insight Summary
            Text("Insights:")
                .font(.headline)
            Text(generateInsights(for: selectedComparisonPeriod))
                .font(.body)
                .padding(.bottom)

            Spacer()
        }
        .padding()
        .navigationTitle("Step 6: Mood Comparisons")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Function to generate insights based on the selected period (placeholder logic)
    private func generateInsights(for period: String) -> String {
        switch period {
        case "Weekly":
            return "Your mood has been stable overall, with a notable uplift on Oct 4th."
        case "Monthly":
            return "This month has shown a significant improvement in mood, compared to last month."
        case "Yearly":
            return "Your mood has seen consistent improvement throughout the year."
        default:
            return "No insights available."
        }
    }
}

// Preview for Step 6
struct Step6View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step6View()
        }
    }
}

*/

// Weekly Insights (Step 7)
struct Step7View: View {
    @State private var moodData: [WeeklyMoodEntry] = [
        WeeklyMoodEntry(day: "Mon", moodRating: 4, stressLevel: 2),
        WeeklyMoodEntry(day: "Tue", moodRating: 3, stressLevel: 3),
        WeeklyMoodEntry(day: "Wed", moodRating: 5, stressLevel: 1),
        WeeklyMoodEntry(day: "Thu", moodRating: 2, stressLevel: 4),
        WeeklyMoodEntry(day: "Fri", moodRating: 3, stressLevel: 3),
        WeeklyMoodEntry(day: "Sat", moodRating: 4, stressLevel: 2),
        WeeklyMoodEntry(day: "Sun", moodRating: 3, stressLevel: 3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Weekly Insights")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("View a summary of your weekly mood")
                .font(.body)
                .foregroundColor(.gray) // Optional: lighter color for description
                .padding(.bottom, 20) // Extra bottom padding for spacing
            
            // Mood and Stress Charts
            Text("Mood Ratings Over the Week")
                .font(.headline)
                .padding(.bottom, 5) // Padding between title and chart
            
            Chart {
                ForEach(moodData) { entry in
                    LineMark(
                        x: .value("Day", entry.day),
                        y: .value("Mood Rating", entry.moodRating)
                    )
                    .symbol(Circle())
                    .foregroundStyle(Color.blue)
                }
            }
            .frame(height: 150)
            .padding(.bottom, 20) // Padding below the chart
            
            Text("Stress Levels Over the Week")
                .font(.headline)
                .padding(.bottom, 5) // Padding between title and chart
            
            Chart {
                ForEach(moodData) { entry in
                    BarMark(
                        x: .value("Day", entry.day),
                        y: .value("Stress Level", entry.stressLevel)
                    )
                    .foregroundStyle(Color.red.opacity(0.7))
                }
            }
            .frame(height: 150)
            .padding(.bottom, 20) // Padding below the chart
            
            // Weekly Highlights
            Text("Weekly Highlights")
                .font(.headline)
                .padding(.bottom, 5) // Padding between title and highlights
            
            Text(generateWeeklyHighlights())
                .font(.body)
                .foregroundColor(.black) // Ensure highlights text is prominent
                .lineLimit(nil) // Allow for multiple lines
                .multilineTextAlignment(.leading) // Align text to the leading edge
                .padding(.bottom)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Step 7: Weekly Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Function to generate weekly highlights (placeholder logic)
    private func generateWeeklyHighlights() -> String {
        return """
        This week, your mood was highest on Wednesday with a rating of 5.
        Stress levels were highest on Thursday. 
        Keep up with activities that bring you joy and consider taking a break on more stressful days.
        """
    }
}

// Model for Weekly Mood Data
struct WeeklyMoodEntry: Identifiable {
    let id = UUID()
    let day: String
    let moodRating: Int
    let stressLevel: Int
}

// Preview for Step 7
struct Step7View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step7View()
        }
    }
}


// Stress and Mood Correlation (Step 8)

// Preview for Step 8

struct Step8View: View {
    @State private var moodData: [MyAppWeeklyMoodEntry] = [
        MyAppWeeklyMoodEntry(day: "Mon", moodRating: 4, stressLevel: 2),
        MyAppWeeklyMoodEntry(day: "Tue", moodRating: 3, stressLevel: 3),
        MyAppWeeklyMoodEntry(day: "Wed", moodRating: 5, stressLevel: 1),
        MyAppWeeklyMoodEntry(day: "Thu", moodRating: 2, stressLevel: 4),
        MyAppWeeklyMoodEntry(day: "Fri", moodRating: 3, stressLevel: 3),
        MyAppWeeklyMoodEntry(day: "Sat", moodRating: 4, stressLevel: 2),
        MyAppWeeklyMoodEntry(day: "Sun", moodRating: 3, stressLevel: 3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and Description
            Text("Stress and Mood Correlation")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Understand the correlation between your stress levels and mood changes. This feature helps you identify how fluctuations in stress might impact your mood.")
                .font(.body)
                .padding(.bottom)
            
            // Correlation Chart
            Text("Stress vs Mood Correlation")
                .font(.headline)
            
            Chart {
                ForEach(moodData) { entry in
                    PointMark(
                        x: .value("Stress Level", entry.stressLevel),
                        y: .value("Mood Rating", entry.moodRating)
                    )
                    .symbol(Circle())
                    .foregroundStyle(Color.blue.opacity(0.7))
                }
            }
            .frame(height: 250)
            .padding(.bottom)
            
            // Summary of Correlation
            Text("Correlation Summary")
                .font(.headline)
            Text(generateCorrelationSummary())
                .font(.body)
                .padding(.bottom)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Step 8: Stress and Mood Correlation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Function to generate correlation summary (placeholder logic)
    private func generateCorrelationSummary() -> String {
        return """
        Generally, as stress levels increase, mood ratings tend to decrease.
        This suggests a negative correlation between stress and mood. Consider activities that lower stress for better mood stability.
        """
    }
}

// Model for Weekly Mood Data
struct MyAppWeeklyMoodEntry: Identifiable {
    let id = UUID() // Unique identifier
    let day: String // Day of the week
    let moodRating: Int // Mood rating (1-5)
    let stressLevel: Int // Stress level (1-5)
}

// Preview for Step 8
struct Step8View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step8View()
        }
    }
}

// Mental Health Resources (Step 9)

// Preview for Step 9

struct Step9View: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mental Health Resources")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Access resources to improve your mental well-being. Explore articles, apps, helplines, and more to support your mental health journey.")
                .font(.body)
                .padding(.bottom)
            
            List {
                Section(header: Text("Articles")) {
                    Link("10 Ways to Boost Your Mental Health", destination: URL(string: "https://www.example.com/mental-health-tips")!)
                    Link("Understanding Anxiety and Stress", destination: URL(string: "https://www.example.com/anxiety-guide")!)
                }
                
                Section(header: Text("Recommended Apps")) {
                    Link("Calm - Meditation and Sleep", destination: URL(string: "https://www.calm.com")!)
                    Link("Headspace - Mindfulness", destination: URL(string: "https://www.headspace.com")!)
                }
                
                Section(header: Text("Helplines")) {
                    Text("National Helpline: 1-800-273-TALK")
                    Text("Mental Health Support: 1-800-662-HELP")
                }
                
                Section(header: Text("Videos")) {
                    Link("Mindfulness for Beginners", destination: URL(string: "https://www.example.com/mindfulness-video")!)
                    Link("Stress Relief Techniques", destination: URL(string: "https://www.example.com/stress-relief-video")!)
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Spacer()
        }
        .padding()
        .navigationTitle("Step 9: Mental Health Resources")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for Step 9
struct Step9View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step9View()
        }
    }
}

// Stress Management (Step 10)

// Preview for Step 10

struct Step10View: View {
    var body: some View {
        ScrollView { // Use ScrollView for better navigation in case of long content
            VStack(alignment: .leading, spacing: 20) {
                Text("Stress Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Learn techniques for managing your stress more effectively. Here are some practical strategies you can use:")
                    .font(.body)
                    .padding(.bottom)

                // Stress Management Techniques
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Mindfulness Meditation")
                        .font(.headline)
                    Text("Practice mindfulness to stay present and reduce anxiety. Start with 5-10 minutes daily.")
                    
                    Text("2. Deep Breathing Exercises")
                        .font(.headline)
                    Text("Inhale deeply through your nose, hold for a few seconds, then exhale slowly through your mouth.")

                    Text("3. Regular Physical Activity")
                        .font(.headline)
                    Text("Engage in physical activities like walking, jogging, or yoga to help release built-up tension.")

                    Text("4. Journaling")
                        .font(.headline)
                    Text("Write down your thoughts and feelings to gain clarity and reduce stress.")

                    Text("5. Connect with Nature")
                        .font(.headline)
                    Text("Spend time outdoors, whether it's a walk in the park or simply sitting in your backyard.")

                    Text("6. Time Management")
                        .font(.headline)
                    Text("Prioritize tasks and break them into smaller steps to avoid feeling overwhelmed.")

                    Text("7. Seek Support")
                        .font(.headline)
                    Text("Talk to friends, family, or a mental health professional when you're feeling stressed.")
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Step 10: Stress Management")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for Step 10
struct Step10View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step10View()
        }
    }
}

// Tips and Suggestions (Step 11)

// Preview for Step 11

struct Step11View: View {
    var body: some View {
        ScrollView { // Use ScrollView for better navigation
            VStack(alignment: .leading, spacing: 20) {
                Text("Tips and Suggestions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Get personalized tips and suggestions to improve your mental health. Here are some practical strategies:")
                    .font(.body)
                    .padding(.bottom)

                // Tips Categories
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Self-Care Practices")
                        .font(.headline)
                    Text("• Take time for yourself daily, even if it’s just a few minutes of quiet time.")
                    Text("• Engage in hobbies that bring you joy and relaxation.")

                    Text("2. Building Connections")
                        .font(.headline)
                    Text("• Reach out to friends or family regularly for support.")
                    Text("• Join a community or support group to meet others with similar interests.")

                    Text("3. Healthy Lifestyle Choices")
                        .font(.headline)
                    Text("• Maintain a balanced diet rich in fruits, vegetables, and whole grains.")
                    Text("• Aim for at least 30 minutes of physical activity most days of the week.")

                    Text("4. Mindfulness and Relaxation")
                        .font(.headline)
                    Text("• Practice mindfulness techniques such as meditation or yoga.")
                    Text("• Explore guided imagery or progressive muscle relaxation exercises.")

                    Text("5. Goal Setting")
                        .font(.headline)
                    Text("• Set small, achievable goals to boost your confidence.")
                    Text("• Celebrate your accomplishments, no matter how small.")

                    Text("6. Seeking Professional Help")
                        .font(.headline)
                    Text("• Don’t hesitate to reach out to a mental health professional if you need support.")
                    Text("• Therapy can provide valuable tools for managing stress and anxiety.")
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Step 11: Tips and Suggestions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for Step 11
struct Step11View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step11View()
        }
    }
}


// Self-Care Suggestions (Step 12)


// Preview for Step 12

struct Step12View: View {
    var body: some View {
        ScrollView { // Use ScrollView for better navigation
            VStack(alignment: .leading, spacing: 20) {
                Text("Self-Care Suggestions")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                Text("Get suggestions for self-care activities to boost your mental health. Here are some ideas to inspire your self-care routine:")
                    .font(.body)
                    .padding(.bottom)

                // Self-Care Activities
                VStack(alignment: .leading, spacing: 15) {
                    Text("1. Physical Self-Care")
                        .font(.headline)
                    Text("• Go for a walk or run in nature.")
                    Text("• Try a new exercise class or routine.")
                    Text("• Practice yoga or stretching to relieve tension.")

                    Text("2. Emotional Self-Care")
                        .font(.headline)
                    Text("• Write in a journal to express your thoughts and feelings.")
                    Text("• Create a playlist of your favorite uplifting songs.")
                    Text("• Allow yourself to cry or laugh; both are healthy outlets.")

                    Text("3. Social Self-Care")
                        .font(.headline)
                    Text("• Schedule regular catch-ups with friends or family.")
                    Text("• Join a club or group that aligns with your interests.")
                    Text("• Volunteer for a cause you care about to connect with others.")

                    Text("4. Mental Self-Care")
                        .font(.headline)
                    Text("• Read a book or listen to an audiobook.")
                    Text("• Engage in puzzles or games that challenge your mind.")
                    Text("• Limit screen time and take breaks from social media.")

                    Text("5. Spiritual Self-Care")
                        .font(.headline)
                    Text("• Spend time in meditation or prayer.")
                    Text("• Explore your spirituality through nature or art.")
                    Text("• Reflect on your values and what brings you peace.")

                    Text("6. Creative Self-Care")
                        .font(.headline)
                    Text("• Try a new craft or artistic hobby, like painting or knitting.")
                    Text("• Cook or bake something new and enjoy the process.")
                    Text("• Start a DIY project to enhance your living space.")
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Step 12: Self-Care Suggestions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for Step 12
struct Step12View_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Step12View()
        }
    }
}
