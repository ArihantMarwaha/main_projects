//
//  nested_navigationView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 23/07/25.
//

import SwiftUI

struct nested_navigationView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    nested_navigationView()
}

struct Topic: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtopics: [Subtopic]
}

struct Subtopic: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
}

struct TopicListView: View {
    let topics = [
        Topic(name: "SwiftUI", subtopics: [
            Subtopic(title: "Intro", description: "SwiftUI basics."),
            Subtopic(title: "Modifiers", description: "View customization."),
            Subtopic(title: "Layouts", description: "Stacks and grids.")
        ]),
        Topic(name: "CoreML", subtopics: [
            Subtopic(title: "Getting Started", description: "What is CoreML?"),
            Subtopic(title: "Model Integration", description: "How to use models.")
        ]),
        Topic(name: "iOS Dev", subtopics: [
            Subtopic(title: "Xcode", description: "How to use Xcode."),
            Subtopic(title: "App Lifecycle", description: "How apps run on iOS.")
        ])
    ]

    var body: some View {
        NavigationStack {
            List(topics) { topic in
                NavigationLink(value: topic) {
                    Text(topic.name)
                }
            }
            .navigationDestination(for: Topic.self) { topic in
                SubtopicListView(topic: topic)
            }
            .navigationDestination(for: Subtopic.self) { subtopic in
                SubtopicDetailView(subtopic: subtopic)
            }
            .navigationTitle("Topics")
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .ignoresSafeArea(.keyboard)
    }
    
    
}

struct SubtopicListView: View {
    let topic: Topic

    var body: some View {
        List(topic.subtopics) { subtopic in
            NavigationLink(value: subtopic) {
                Text(subtopic.title)
            }
        }
        .navigationTitle(topic.name)
    }
}

struct SubtopicDetailView: View {
    let subtopic: Subtopic

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(subtopic.title)
                .font(.title)
            Text(subtopic.description)
                .font(.body)
        }
        .padding()
        .navigationTitle("Subtopic")
    }
}

#Preview{
    TopicListView()
}
