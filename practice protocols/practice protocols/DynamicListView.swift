//
//  DynamicListView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 23/07/25.
//

import SwiftUI

struct dynamical : Identifiable {
    let id = UUID()
    let title: String
    let isDone: Bool
}

struct DynamicListView: View {
    
    let task = [
        dynamical(title: "Arihant", isDone: true),
        dynamical(title: "Dally", isDone: false),
        dynamical(title: "Moon", isDone: true)
        
    ]
    
    
    
    var body: some View {
        List(task){
            task in HStack{
                Text(task.title)
                Spacer()
                                if task.isDone {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
            }
            
        }
    }
}

#Preview {
    DynamicListView()
}


struct EditableListView: View {
    @State private var items = ["Math", "Science", "English"]

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .background()
            .navigationTitle("Subjects")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(){
                    Button("port") {
                        items.append("New Subject")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        items.append("New Subject")
                    }
                }
            }
        }
        
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}


#Preview{
    EditableListView()
}


struct Course: Identifiable {
    let id = UUID()
    let name: String
}

struct CourseListView: View {
    let courses = [
        Course(name: "SwiftUI"),
        Course(name: "AI with CoreML")
    ]

    var body: some View {
        NavigationStack {
            List(courses) { course in
                NavigationLink(destination:EditableListView()) {
                    Text(course.name)
                }
            }
            .navigationTitle("Courses")
        }
    }
}

#Preview{
    CourseListView()
}




//rainbow list
struct Student: Identifiable {
    let id = UUID()
    let name: String
    let score: Int
}


struct CustomRowListView: View {
    let students = [
        Student(name: "Arihant", score: 98),
        Student(name: "Meena", score: 85),
        Student(name: "Yash", score: 91)
    ]

    var body: some View {
        List(students) { student in
            HStack {
                VStack(alignment: .leading) {
                    Text(student.name).font(.headline)
                    Text("Score: \(student.score)").font(.subheadline)
                }
                Spacer()
                if student.score > 90 {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview{
    CustomRowListView()
}


//sectioned list
struct GroceryListView: View {
    var body: some View {
        List {
            Section(header: Text("Fruits")) {
                Text("Apple")
                Text("Banana")
            }

            Section(header: Text("Vegetables")) {
                Text("Carrot")
                Text("Spinach")
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview{
    GroceryListView()
}

//infinite list View
struct InfiniteListView: View {
    @State private var numbers = Array(1...20)

    var body: some View {
        List(numbers, id: \.self) { number in
            Text("Item \(number)")
                .onAppear {
                    if number == numbers.last {
                        loadMore()
                    }
                }
        }
    }

    func loadMore() {
        let next = (numbers.last ?? 0) + 1
        numbers.append(contentsOf: next..<next+10)
    }
}

#Preview{
    InfiniteListView()
}
