//
//  AppearanceManager.swift
//  GUGUios
//
//  Manages app-wide appearance settings including color scheme, accent color, and font size
//

import SwiftUI
import Combine

@MainActor
class AppearanceManager: ObservableObject {
    static let shared = AppearanceManager()
    
    @AppStorage("selectedColorScheme") var selectedColorScheme: String = "system" {
        didSet {
            applyColorScheme()
        }
    }
    
    @AppStorage("selectedAccentColor") var selectedAccentColor: String = "blue" {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("fontSize") var fontSize: String = "medium" {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("enableAnimations") var enableAnimations: Bool = true {
        didSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage("reducedMotion") var reducedMotion: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
    
    private init() {
        // Apply initial color scheme
        applyColorScheme()
    }
    
    // MARK: - Color Scheme Management
    
    var currentColorScheme: ColorScheme? {
        switch selectedColorScheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // System default
        }
    }
    
    private func applyColorScheme() {
        // This will be handled by the view modifier
        objectWillChange.send()
    }
    
    // MARK: - Accent Color Management
    
    var accentColor: Color {
        switch selectedAccentColor {
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "yellow": return .yellow
        case "teal": return .teal
        default: return .blue
        }
    }
    
    // MARK: - Font Size Management
    
    var bodyFont: Font {
        switch fontSize {
        case "small": return .caption
        case "large": return .title3
        case "extraLarge": return .title2
        default: return .body
        }
    }
    
    var headlineFont: Font {
        switch fontSize {
        case "small": return .body
        case "large": return .title2
        case "extraLarge": return .title
        default: return .headline
        }
    }
    
    var titleFont: Font {
        switch fontSize {
        case "small": return .headline
        case "large": return .largeTitle
        case "extraLarge": return .system(size: 36, weight: .bold)
        default: return .title
        }
    }
    
    var captionFont: Font {
        switch fontSize {
        case "small": return .system(size: 10)
        case "large": return .body
        case "extraLarge": return .headline
        default: return .caption
        }
    }
    
    // MARK: - Animation Management
    
    var animationDuration: Double {
        if !enableAnimations || reducedMotion {
            return 0.0
        }
        return 0.3
    }
    
    var springAnimation: Animation? {
        if !enableAnimations || reducedMotion {
            return nil
        }
        return .spring(response: 0.5, dampingFraction: 0.7)
    }
    
    var easeInOutAnimation: Animation? {
        if !enableAnimations || reducedMotion {
            return nil
        }
        return .easeInOut(duration: animationDuration)
    }
}

// MARK: - View Extension for Easy Access

extension View {
    func applyAppearanceSettings() -> some View {
        self.modifier(AppearanceModifier())
    }
}

struct AppearanceModifier: ViewModifier {
    @StateObject private var appearanceManager = AppearanceManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(appearanceManager.currentColorScheme)
            .accentColor(appearanceManager.accentColor)
            .dynamicTypeSize(dynamicTypeSize)
            .environmentObject(appearanceManager)
    }
    
    private var dynamicTypeSize: DynamicTypeSize {
        switch appearanceManager.fontSize {
        case "small":
            return .small
        case "large":
            return .large
        case "extraLarge":
            return .xLarge
        default:
            return .medium
        }
    }
}