//
//  SettingsView.swift
//  GUGUios
//
//  Settings view with migration controls and app preferences
//

import SwiftUI
import SwiftData
import UserNotifications
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var goalsManager: GoalsManager
    
    @State private var showDeleteConfirmation = false
    @State private var showContactAlert = false
    @State private var contactErrorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                // Data Management Section
                Section {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("Manage Data", systemImage: "folder")
                    }
                    .accessibilityHint("View data management options including backup and storage information")
                } header: {
                    Text("Data Management")
                }
                
                // App Preferences Section
                Section {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                    .accessibilityHint("Configure notification preferences for goals, pet, and reminders")
                    
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                    .accessibilityHint("Customize app appearance including theme, colors, and text size")
                    
                    NavigationLink {
                        PrivacySettingsView()
                    } label: {
                        Label("Privacy", systemImage: "lock")
                    }
                    .accessibilityHint("View privacy settings and data controls")
                    
                } header: {
                    Text("App Preferences")
                }
                
                // Support Section
                Section {
                    Button {
                        contactSupport()
                    } label: {
                        Label("Contact Support", systemImage: "envelope")
                    }
                    .accessibilityHint("Send an email to our support team for help")
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                    .accessibilityHint("View app information, version, and credits")
                } header: {
                    Text("Support")
                } footer: {
                    Text("Get help with your account, report bugs, or send feedback to our team.")
                }
                
                
                // Danger Zone
                Section {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    .accessibilityHint("Warning: This will permanently delete all your app data")
                } header: {
                    Text("Danger Zone")
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your data including goals, journal entries, and pet progress. This action cannot be undone.")
            }
            .alert("Contact Support", isPresented: $showContactAlert) {
                Button("Copy Email") {
                    UIPasteboard.general.string = "support@gugu.app"
                }
                Button("OK", role: .cancel) { }
            } message: {
                Text(contactErrorMessage)
            }
        }
    }
    
    private func resetAllData() {
        do {
            // Clear all SwiftData models systematically
            try modelContext.delete(model: SDGoal.self)
            try modelContext.delete(model: SDGoalEntry.self)
            try modelContext.delete(model: SDJournalEntry.self)
            try modelContext.delete(model: SDAnalytics.self)
            try modelContext.delete(model: SDPetData.self)
            try modelContext.delete(model: SDGoalStreak.self)
            try modelContext.save()
            
            print("✅ Successfully reset all app data")
            
        } catch {
            print("❌ Failed to reset data: \(error.localizedDescription)")
        }
    }
    
    private func contactSupport() {
        // Primary method: mailto link
        if let emailUrl = URL(string: "mailto:arihantmarwahacv@gmail.com?subject=GUGU%20App%20Support") {
            if UIApplication.shared.canOpenURL(emailUrl) {
                UIApplication.shared.open(emailUrl)
                return
            }
        }
        
        // Fallback 1: Try opening default mail app
        if let mailUrl = URL(string: "mailto:") {
            if UIApplication.shared.canOpenURL(mailUrl) {
                contactErrorMessage = "Please send an email to: arihantmarwahacv@gmail.com"
                showContactAlert = true
                return
            }
        }
        
        // Fallback 2: Show contact information
        contactErrorMessage = "No email app found. Please contact us at:\narihantmarwahacv@gmail.com"
        showContactAlert = true
    }
}

// MARK: - Export Options View
struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Export Feature")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Data export functionality is coming soon. Your data is safely stored locally on your device.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views
struct DataManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var goalsManager: GoalsManager
    
    @State private var showClearEntriesConfirmation = false
    @State private var showDeleteAllConfirmation = false
    @State private var storageInfo = StorageInfo()
    @State private var isCalculatingStorage = false
    
    var body: some View {
        List {
            // Storage Information Section
            Section {
                if isCalculatingStorage {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Calculating storage...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    StorageInfoRow(title: "Goals", count: storageInfo.goalCount, icon: "target")
                    StorageInfoRow(title: "Goal Entries", count: storageInfo.entryCount, icon: "list.bullet")
                    StorageInfoRow(title: "Journal Entries", count: storageInfo.journalCount, icon: "book")
                    StorageInfoRow(title: "Pet Data", count: storageInfo.petDataExists ? 1 : 0, icon: "heart")
                    StorageInfoRow(title: "Achievements", count: storageInfo.achievementCount, icon: "trophy")
                }
                
                Button {
                    calculateStorageInfo()
                } label: {
                    Label("Refresh Storage Info", systemImage: "arrow.clockwise")
                }
                .disabled(isCalculatingStorage)
            } header: {
                Text("Storage Information")
            } footer: {
                Text("View how much data is stored in the app.")
            }
            
            // Backup & Restore Section
            Section {
                VStack(spacing: 8) {
                    Image(systemName: "icloud")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Your data is stored locally and securely on your device")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            } header: {
                Text("Data Storage")
            } footer: {
                Text("All your information is kept private and stored only on your device.")
            }
            
            // Data Cleanup Section
            Section {
                Button {
                    showClearEntriesConfirmation = true
                } label: {
                    Label("Clear All Entries", systemImage: "trash")
                        .foregroundColor(.orange)
                }
                
                Button {
                    showDeleteAllConfirmation = true
                } label: {
                    Label("Reset All Data", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                }
            } header: {
                Text("Data Cleanup")
            } footer: {
                Text("These actions cannot be undone. Make sure to export your data first.")
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            calculateStorageInfo()
        }
        .confirmationDialog("Clear All Entries", isPresented: $showClearEntriesConfirmation) {
            Button("Clear Entries", role: .destructive) {
                clearAllEntries()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete all goal entries but keep your goals, settings, and pet data. This cannot be undone.")
        }
        .confirmationDialog("Reset All Data", isPresented: $showDeleteAllConfirmation) {
            Button("Reset Everything", role: .destructive) {
                resetAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will delete ALL data including goals, entries, pet data, achievements, and settings. This cannot be undone.")
        }
    }
    
    private func calculateStorageInfo() {
        isCalculatingStorage = true
        
        Task {
            do {
                let goalCount = try modelContext.fetchCount(FetchDescriptor<SDGoal>())
                let entryCount = try modelContext.fetchCount(FetchDescriptor<SDGoalEntry>())
                let journalCount = try modelContext.fetchCount(FetchDescriptor<SDJournalEntry>())
                let achievementCount = 0 // Achievement system removed
                let petDataCount = try modelContext.fetchCount(FetchDescriptor<SDPetData>())
                
                await MainActor.run {
                    storageInfo = StorageInfo(
                        goalCount: goalCount,
                        entryCount: entryCount,
                        journalCount: journalCount,
                        achievementCount: achievementCount,
                        petDataExists: petDataCount > 0
                    )
                    isCalculatingStorage = false
                }
            } catch {
                await MainActor.run {
                    storageInfo = StorageInfo()
                    isCalculatingStorage = false
                }
            }
        }
    }
    
    private func clearAllEntries() {
        do {
            try modelContext.delete(model: SDGoalEntry.self)
            try modelContext.save()
            calculateStorageInfo()
        } catch {
            print("Failed to clear entries: \(error)")
        }
    }
    
    private func resetAllData() {
        do {
            try modelContext.delete(model: SDGoal.self)
            try modelContext.delete(model: SDGoalEntry.self)
            try modelContext.delete(model: SDJournalEntry.self)
            try modelContext.delete(model: SDAnalytics.self)
            try modelContext.delete(model: SDPetData.self)
            try modelContext.delete(model: SDGoalStreak.self)
            try modelContext.save()
            calculateStorageInfo()
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}

struct StorageInfo {
    var goalCount: Int = 0
    var entryCount: Int = 0
    var journalCount: Int = 0
    var achievementCount: Int = 0
    var petDataExists: Bool = false
}

struct StorageInfoRow: View {
    let title: String
    let count: Int
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
            
            Spacer()
            
            Text("\(count)")
                .foregroundColor(.secondary)
        }
    }
}

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert = false
    @State private var permissionStatus = "Unknown"
    
    var body: some View {
        List {
            // Permission Status Section
            Section {
                HStack {
                    Image(systemName: notificationManager.isPermissionGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(notificationManager.isPermissionGranted ? .green : .red)
                    
                    VStack(alignment: .leading) {
                        Text("Notification Permission")
                            .font(.headline)
                        Text(notificationManager.isPermissionGranted ? "Granted" : "Not Granted")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !notificationManager.isPermissionGranted {
                        Button("Enable") {
                            Task {
                                await requestNotificationPermission()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } header: {
                Text("Permission Status")
            } footer: {
                if !notificationManager.isPermissionGranted {
                    Text("Enable notifications to receive reminders about your goals and pet care.")
                }
            }
            
            // Notification Types Section
            Section {
                NotificationToggleRow(
                    title: "Goal Reminders",
                    description: "Get reminded about incomplete goals",
                    icon: "target",
                    isEnabled: $notificationManager.notificationSettings.goalReminders
                )
                
                NotificationToggleRow(
                    title: "Cooldown Notifications",
                    description: "Know when you can log your next entry",
                    icon: "clock",
                    isEnabled: $notificationManager.notificationSettings.cooldownNotifications
                )
                
                NotificationToggleRow(
                    title: "Pet Check-ins",
                    description: "Regular reminders to check on your pet", 
                    icon: "heart",
                    isEnabled: $notificationManager.notificationSettings.petCheckIns
                )
                
                NotificationToggleRow(
                    title: "Pet State Alerts",
                    description: "Urgent notifications when your pet needs care",
                    icon: "exclamationmark.triangle",
                    isEnabled: $notificationManager.notificationSettings.petStateAlerts
                )
                
                NotificationToggleRow(
                    title: "Motivational Messages",
                    description: "Encouraging reminders throughout the day",
                    icon: "star",
                    isEnabled: $notificationManager.notificationSettings.motivationalMessages
                )
                
                NotificationToggleRow(
                    title: "Streak Notifications",
                    description: "Celebrate your goal streaks",
                    icon: "flame",
                    isEnabled: $notificationManager.notificationSettings.streakNotifications
                )
                
                NotificationToggleRow(
                    title: "Daily Summary",
                    description: "Evening recap of your daily progress",
                    icon: "chart.bar",
                    isEnabled: $notificationManager.notificationSettings.dailySummary
                )
            } header: {
                Text("Notification Types")
            }
            
            // Timing Preferences Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goal Reminder Interval")
                        .font(.headline)
                    Text("How often to remind you about incomplete goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Goal Reminder Interval", selection: $notificationManager.notificationSettings.goalReminderInterval) {
                        Text("1h").tag(3600.0)
                        Text("2h").tag(7200.0)
                        Text("3h").tag(10800.0)
                        Text("6h").tag(21600.0)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pet Check-in Interval")
                        .font(.headline)
                    Text("How often to remind you to check on your pet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Pet Check-in Interval", selection: $notificationManager.notificationSettings.petCheckInInterval) {
                        Text("3h").tag(10800.0)
                        Text("6h").tag(21600.0)
                        Text("12h").tag(43200.0)
                        Text("24h").tag(86400.0)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motivational Messages")
                        .font(.headline)
                    Text("How often to send encouraging messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Motivational Interval", selection: $notificationManager.notificationSettings.motivationalInterval) {
                        Text("2h").tag(7200.0)
                        Text("4h").tag(14400.0)
                        Text("6h").tag(21600.0)
                        Text("24h").tag(86400.0)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Timing Preferences")
            } footer: {
                Text("Notification timing is automatically adjusted to avoid quiet hours (10 PM - 8 AM).")
            }
            
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            updatePermissionStatus()
        }
        .alert("Notification Permission", isPresented: $showPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive reminders about your goals and pet care.")
        }
    }
    
    private func requestNotificationPermission() async {
        let granted = await notificationManager.requestPermission()
        if !granted {
            await MainActor.run {
                showPermissionAlert = true
            }
        }
    }
    
    private func updatePermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    permissionStatus = "Not Determined"
                case .denied:
                    permissionStatus = "Denied"
                case .authorized:
                    permissionStatus = "Authorized"
                case .provisional:
                    permissionStatus = "Provisional"
                case .ephemeral:
                    permissionStatus = "Ephemeral"
                @unknown default:
                    permissionStatus = "Unknown"
                }
            }
        }
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct AppearanceSettingsView: View {
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        List {
            // Theme Section
            Section {
                Picker("Color Scheme", selection: $appearanceManager.selectedColorScheme) {
                    Label("System", systemImage: "circle.lefthalf.filled")
                        .tag("system")
                    Label("Light", systemImage: "sun.max")
                        .tag("light")
                    Label("Dark", systemImage: "moon")
                        .tag("dark")
                }
                .pickerStyle(.navigationLink)
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose your preferred color scheme. System automatically switches between light and dark based on your device settings.")
            }
            
            // Accent Color Section
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    AccentColorButton(color: .blue, name: "Blue", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .green, name: "Green", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .orange, name: "Orange", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .purple, name: "Purple", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .red, name: "Red", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .pink, name: "Pink", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .yellow, name: "Yellow", selectedColor: $appearanceManager.selectedAccentColor)
                    AccentColorButton(color: .teal, name: "Teal", selectedColor: $appearanceManager.selectedAccentColor)
                }
                .padding(.vertical, 8)
            } header: {
                Text("Accent Color")
            } footer: {
                Text("Select your preferred accent color for buttons, highlights, and interactive elements.")
            }
            
            // Text Size Section
            Section {
                Picker("Font Size", selection: $appearanceManager.fontSize) {
                    Text("Small").tag("small")
                    Text("Medium").tag("medium")
                    Text("Large").tag("large")
                    Text("Extra Large").tag("extraLarge")
                }
                .pickerStyle(.segmented)
            } header: {
                Text("Text Size")
            } footer: {
                Text("Adjust the text size for better readability. This affects most text in the app.")
            }
            
            // Preview Section
            Section {
                AppearancePreview()
            } header: {
                Text("Preview")
            } footer: {
                Text("See how your appearance settings will look.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccentColorButton: View {
    let color: Color
    let name: String
    @Binding var selectedColor: String
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                selectedColor = name.lowercased()
            } label: {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                    .overlay {
                        if selectedColor == name.lowercased() {
                            Circle()
                                .stroke(Color.primary, lineWidth: 3)
                        }
                    }
                    .overlay {
                        if selectedColor == name.lowercased() {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(name) accent color")
            .accessibilityValue(selectedColor == name.lowercased() ? "Selected" : "Not selected")
            .accessibilityHint("Double tap to select \(name.lowercased()) as your accent color")
            
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct AppearancePreview: View {
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Title Example
            Text("Sample Title")
                .font(appearanceManager.titleFont)
                .fontWeight(.bold)
            
            // Goal Example
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(appearanceManager.accentColor)
                Text("Daily Goal")
                    .font(appearanceManager.headlineFont)
                Spacer()
                Text("3/5")
                    .font(appearanceManager.bodyFont)
                    .foregroundColor(.secondary)
            }
            
            // Progress Bar
            ThemedProgressView(value: 0.6, total: 1.0)
            
            // Body Text Example
            Text("This is sample body text that changes size based on your font preference.")
                .font(appearanceManager.bodyFont)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Button Example
            ThemedButton(title: "Sample Button", action: {
                // Preview button action
            }, style: .primary)
        }
        .themedCard()
    }
}

struct PrivacySettingsView: View {
    @State private var showPrivacyPolicy = false
    @State private var showPrivacyContactAlert = false
    @State private var privacyContactErrorMessage = ""
    
    var body: some View {
        List {
            
            // Privacy Information Section
            Section {
                Button {
                    showPrivacyPolicy = true
                } label: {
                    Label("Privacy Policy", systemImage: "doc.text")
                }
                
                Button {
                    contactPrivacyTeam()
                } label: {
                    Label("Contact Privacy Team", systemImage: "envelope")
                }
                
                NavigationLink {
                    ThirdPartyLicensesView()
                } label: {
                    Label("Third-Party Licenses", systemImage: "list.bullet.rectangle")
                }
            } header: {
                Text("Privacy Information")
            } footer: {
                Text("Learn more about how we protect your privacy and handle your data.")
            }
            
            // Security Section
            Section {
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("Local Storage")
                            .font(.headline)
                        Text("Your data is stored locally on your device")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "checkmark.shield")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("No Account Required")
                            .font(.headline)
                        Text("No registration or login needed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "hand.raised.slash")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("No Tracking")
                            .font(.headline)
                        Text("We don't track your activity or behavior")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Security Features")
            } footer: {
                Text("GUGU is designed with privacy in mind. Your personal data stays on your device.")
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .alert("Contact Privacy Team", isPresented: $showPrivacyContactAlert) {
            Button("Copy Email") {
                UIPasteboard.general.string = "arihantmarwahacv@gmail.com"
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(privacyContactErrorMessage)
        }
    }
    
    private func contactPrivacyTeam() {
        // Primary method: mailto link with privacy subject
        if let emailUrl = URL(string: "mailto:arihantmarwahacv@gmail.com?subject=Privacy%20Inquiry%20-%20GUGU%20App") {
            if UIApplication.shared.canOpenURL(emailUrl) {
                UIApplication.shared.open(emailUrl)
                return
            }
        }
        
        // Fallback 1: Try opening default mail app
        if let mailUrl = URL(string: "mailto:") {
            if UIApplication.shared.canOpenURL(mailUrl) {
                privacyContactErrorMessage = "Please send an email to: arihantmarwahacv@gmail.com\n\nSubject: Privacy Inquiry - GUGU App"
                showPrivacyContactAlert = true
                return
            }
        }
        
        // Fallback 2: Show contact information
        privacyContactErrorMessage = "No email app found. Please contact us at:\narihantmarwahacv@gmail.com\n\nFor privacy-related questions, data requests, or concerns about your personal information."
        showPrivacyContactAlert = true
    }
}

struct DataUsageView: View {
    var body: some View {
        List {
            Section {
                DataUsageRow(category: "Goals", description: "Your goal titles, targets, and settings", dataType: "Local Only")
                DataUsageRow(category: "Entries", description: "Goal completion timestamps and progress", dataType: "Local Only")
                DataUsageRow(category: "Pet Data", description: "Pet stats, state, and customization", dataType: "Local Only")
                DataUsageRow(category: "Settings", description: "App preferences and notification settings", dataType: "Local Only")
            } header: {
                Text("Data Categories")
            } footer: {
                Text("All data is stored locally on your device and is never transmitted to external servers.")
            }
        }
        .navigationTitle("Data Usage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DataUsageRow: View {
    let category: String
    let description: String
    let dataType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(category)
                    .font(.headline)
                Spacer()
                Text(dataType)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.green.opacity(0.2))
                    .foregroundColor(.green)
                    .clipShape(Capsule())
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct ThirdPartyLicensesView: View {
    var body: some View {
        List {
            Section {
                Text("This app uses the following third-party libraries and frameworks:")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Section {
                LicenseRow(
                    name: "SwiftUI",
                    description: "Apple's declarative UI framework",
                    license: "Apple Software License"
                )
                
                LicenseRow(
                    name: "SwiftData",
                    description: "Apple's data persistence framework",
                    license: "Apple Software License"
                )
                
                LicenseRow(
                    name: "UserNotifications",
                    description: "Apple's notification framework",
                    license: "Apple Software License"
                )
            } header: {
                Text("Apple Frameworks")
            }
        }
        .navigationTitle("Third-Party Licenses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LicenseRow: View {
    let name: String
    let description: String
    let license: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            Text(license)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 2)
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Last updated: \(Date().formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Data Collection")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("GUGU is designed with privacy as a priority. We do not collect, store, or transmit any personal data to external servers. All your information is stored locally on your device.")
                    }
                    
                    Group {
                        Text("Information We Don't Collect")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Personal identifying information")
                            Text("• Location data")
                            Text("• Device identifiers")
                            Text("• Usage analytics (unless explicitly enabled)")
                            Text("• Contact information")
                        }
                        .font(.body)
                    }
                    
                    Group {
                        Text("Local Storage")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("All app data including goals, entries, pet data, and settings are stored locally on your device using Apple's secure storage mechanisms.")
                        
                        Text("Contact Us")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("If you have any questions about this privacy policy, please contact us at arihantmarwahacv@gmail.com")
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        List {
            // App Info Section
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.red)
                    
                    Text("GUGU")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("A companion app to help you build healthy habits and take care of your virtual pet.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
            
            // Developer Section
            Section {
                HStack {
                    Text("Developer")
                    Spacer()
                    Text("GUGU Team")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Copyright")
                    Spacer()
                    Text("© 2025 GUGU")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Developer Information")
            }
            
            // Credits Section
            Section {
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                    Text("Made with love for habit builders")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "swift")
                        .foregroundColor(.orange)
                    Text("Built with Swift & SwiftUI")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "iphone")
                        .foregroundColor(.blue)
                    Text("Designed for iOS")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Credits")
            }
            
            // Legal Section
            Section {
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                
                Link(destination: URL(string: "mailto:arihantmarwahacv@gmail.com?subject=Terms%20of%20Service")!) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
                
                NavigationLink {
                    ThirdPartyLicensesView()
                } label: {
                    Label("Acknowledgments", systemImage: "list.bullet.rectangle")
                }
            } header: {
                Text("Legal")
            }
            
            // Dedication Section
            Section {
                VStack(spacing: 20) {
                    Image("gugu")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220, height: 220)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                    
                    VStack(spacing: 8) {
                        Text("Inspired from the best Doggo in the world")
                            .font(.headline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                        
                        Text("GUGU")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationToggleRow: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    // Create temporary ModelContext for preview
    let schema = Schema([SDGoal.self, SDGoalEntry.self, SDJournalEntry.self, SDAnalytics.self, SDPetData.self, SDGoalStreak.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let modelContext = container.mainContext
    
    SettingsView()
        .environmentObject(GoalsManager(modelContext: modelContext))
        .environmentObject(AppearanceManager.shared)
}
