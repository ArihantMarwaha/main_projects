//
//  StudyBuddyApp.swift
//  StudyBuddy
//
//  Created by Arihant Marwaha on 12/07/25.
//

import SwiftUI

import SwiftUI
import Foundation

@main
struct StudyBuddyApp: App {
    @StateObject private var notesManager = NotesManager()
    @StateObject private var aiService = AIService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notesManager)
                .environmentObject(aiService)
                // Simplified glass effect - remove if causing issues
                .background(WindowBackgroundView())
        }
        .windowStyle(.automatic) // Changed from .hiddenTitleBar for better compatibility
        .defaultSize(width: 1200, height: 800)
        
        // Menu bar commands
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") {
                    notesManager.createNewNote()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("Notes") {
                Button("Export Current Note...") {
                    // Export functionality
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
                .disabled(notesManager.selectedNote == nil)
                
                Divider()
                
                Button("Generate Quiz") {
                    // Quiz generation
                }
                .keyboardShortcut("q", modifiers: [.command, .shift])
                .disabled(notesManager.selectedNote == nil)
            }
        }
    }
}

// Window Background View for Glass Effect simulation
struct WindowBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct ComingSoonView: View {
    let title: String
    let icon: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .symbolRenderingMode(.multicolor)
            
            Text(title)
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            
            Text(description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
}
