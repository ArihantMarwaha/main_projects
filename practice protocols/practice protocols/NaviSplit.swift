//
//  NaviSplit.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 24/07/25.
//

import SwiftUI

struct NaviSplit: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    NaviSplit()
}

struct hollow: View {
    
    @State private var selectedCategory: String? = "Swift"
    @State private var selectedCourse: String?
    
    let categories = ["Swift", "iOS", "CoreML"]
    let courses = [
            "Swift": ["Variables", "Functions", "Protocols"],
            "iOS": ["UIKit", "SwiftUI", "Navigation"],
            "CoreML": ["Models", "Training", "Vision"]
        ]
    
    
    var body: some View {
        
        NavigationSplitView{
            
            List(categories, id: \.self, selection: $selectedCategory) { category in
                          Text(category)
                      }
                      .navigationTitle("Categories")
            
        }content: {
            
            if let selected = selectedCategory,
                           let items = courses[selected] {
                            List(items, id: \.self, selection: $selectedCourse) { course in
                                Text(course)
                            }
                            .navigationTitle("\(selected) Topics")
                        } else {
                            Text("Select a category")
                        }
            
        }detail: {
            
            if let selectedCourse {
                            Text("You selected: \(selectedCourse)")
                                .font(.largeTitle)
                                .padding()
                        } else {
                            Text("Select a course")
                        }
            
        }
        
    }
}

struct NavigationSplitExample_Previews: PreviewProvider {
    static var previews: some View {
        hollow()
    }
}


