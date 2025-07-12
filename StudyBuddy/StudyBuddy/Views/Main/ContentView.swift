//
//  ContentView.swift
//  StudyBuddy
//
//  Created by Arihant Marwaha on 12/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notesManager: NotesManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selectedTab: $selectedTab)
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            switch selectedTab {
            case 0:
                NotesView()
            case 1:
                ComingSoonView(
                    title: "Daily Tasks",
                    icon: "checklist",
                    description: "GUGU - Get Up and Get Going\nComing Soon"
                )
            case 2:
                ComingSoonView(
                    title: "Mental Health Buddy",
                    icon: "heart.circle",
                    description: "Your AI companion for maintaining healthy habits\nComing Soon"
                )
            default:
                EmptyView()
            }
        }
    }
}

