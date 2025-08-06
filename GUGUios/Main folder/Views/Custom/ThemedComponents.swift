//
//  ThemedComponents.swift
//  GUGUios
//
//  Reusable components that respect the app's appearance settings
//

import SwiftUI

// MARK: - Themed Text Components

struct ThemedText: View {
    let text: String
    let style: TextStyle
    
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    enum TextStyle {
        case body, headline, title, caption, largeTitle
    }
    
    var body: some View {
        Text(text)
            .font(fontForStyle)
    }
    
    private var fontForStyle: Font {
        switch style {
        case .body:
            return appearanceManager.bodyFont
        case .headline:
            return appearanceManager.headlineFont
        case .title:
            return appearanceManager.titleFont
        case .caption:
            return appearanceManager.captionFont
        case .largeTitle:
            return appearanceManager.titleFont
        }
    }
}

// MARK: - Themed Button Components

struct ThemedButton: View {
    let title: String
    let action: () -> Void
    let style: ButtonStyle
    
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    enum ButtonStyle {
        case primary, secondary, destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(appearanceManager.bodyFont)
                .foregroundColor(foregroundColor)
                .padding()
                .background(backgroundColor)
                .cornerRadius(10)
        }
        .animation(appearanceManager.easeInOutAnimation, value: appearanceManager.selectedAccentColor)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return appearanceManager.accentColor
        case .secondary:
            return appearanceManager.accentColor.opacity(0.2)
        case .destructive:
            return .red
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return appearanceManager.accentColor
        }
    }
}

// MARK: - Themed Progress View

struct ThemedProgressView: View {
    let value: Double
    let total: Double
    
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    var body: some View {
        ProgressView(value: value, total: total)
            .tint(appearanceManager.accentColor)
            .animation(appearanceManager.springAnimation, value: value)
    }
}

// MARK: - Themed Card View

struct ThemedCard<Content: View>: View {
    let content: Content
    
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .animation(appearanceManager.easeInOutAnimation, value: appearanceManager.selectedColorScheme)
    }
}

// MARK: - View Extensions for Convenience

extension Text {
    func themedBody() -> some View {
        self.modifier(ThemedTextModifier(style: .body))
    }
    
    func themedHeadline() -> some View {
        self.modifier(ThemedTextModifier(style: .headline))
    }
    
    func themedTitle() -> some View {
        self.modifier(ThemedTextModifier(style: .title))
    }
    
    func themedCaption() -> some View {
        self.modifier(ThemedTextModifier(style: .caption))
    }
}

struct ThemedTextModifier: ViewModifier {
    let style: ThemedText.TextStyle
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    func body(content: Content) -> some View {
        content
            .font(fontForStyle)
    }
    
    private var fontForStyle: Font {
        switch style {
        case .body:
            return appearanceManager.bodyFont
        case .headline:
            return appearanceManager.headlineFont
        case .title:
            return appearanceManager.titleFont
        case .caption:
            return appearanceManager.captionFont
        case .largeTitle:
            return appearanceManager.titleFont
        }
    }
}

extension View {
    func themedCard() -> some View {
        ThemedCard {
            self
        }
    }
    
    func themedAnimation<V: Equatable>(_ value: V) -> some View {
        self.modifier(ThemedAnimationModifier(value: value))
    }
}

struct ThemedAnimationModifier<V: Equatable>: ViewModifier {
    let value: V
    @EnvironmentObject private var appearanceManager: AppearanceManager
    
    func body(content: Content) -> some View {
        content
            .animation(appearanceManager.springAnimation, value: value)
    }
}