//
//  Sidebar.swift
//  StudyBuddy
//
//  Created by Arihant Marwaha on 12/07/25.
//

import SwiftUI

struct Sidebar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var notesManager: NotesManager
    
    var body: some View {
        VStack(spacing: 0) {
            // App Title
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .symbolRenderingMode(.multicolor)
                Text("Study Buddy")
                    .font(.title2.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
          
            
            // Navigation Items
            List(selection: $selectedTab) {
                Label("Notes", systemImage: "note.text")
                    .tag(0)
                    .badge(notesManager.notes.count)
                
                Label("Daily Tasks", systemImage: "checklist")
                    .tag(1)
                    .badge("Soon")
                
                Label("Mental Health", systemImage: "heart.circle")
                    .tag(2)
                    .badge("Soon")
            }
            .listStyle(.sidebar)
            
            Spacer()
            
            // Storage Info
            VStack(spacing: 4) {
                Text("Notes: \(notesManager.notes.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let lastModified = notesManager.notes.first?.modifiedAt {
                    Text("Last modified: \(lastModified.formatted(.relative(presentation: .named)))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
        }
    }
}

