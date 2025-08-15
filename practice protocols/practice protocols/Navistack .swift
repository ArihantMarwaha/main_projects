//
//  Navistack .swift
//  practice protocols
//
//  Created by Arihant Marwaha on 23/07/25.
//

import SwiftUI

struct Navistack_: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    Navistack_()
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                NavigationLink("Go to Detail") {
                    Text("This is the Detail View")
                }
                Spacer()
                NavigationLink("Go to home") {
                    Text("This is the home view View")
                }
                Spacer()
                NavigationLink("Go to stack") {
                    Text("This is the stack View")
                }
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

#Preview{
    HomeView()
}


//navigation with a list
struct Courses: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

struct CourseListViews: View {
    let courses = [
        Courses(title: "SwiftUI"),
        Courses(title: "AI with CoreML"),
        Courses(title: "iOS Dev")
    ]

    var body: some View {
        NavigationStack {
            List(courses) { course in
                NavigationLink(course.title, value: course)
            }
            .navigationDestination(for: Courses.self) { course in
                Text("Welcome to \(course.title)")
            }
            .navigationTitle("Courses")
        }
    }
}

#Preview{
    CourseListViews()
}
