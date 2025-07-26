//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

/*struct CategoryFilterView: View {
 @Binding var selectedCategory: GoalCategory?
 let categories: [GoalCategory]
 
 var body: some View {
     ScrollView(.horizontal, showsIndicators: false) {
         HStack(spacing: 12) {
             ForEach(categories, id: \.self) { category in
                 CategoryPill(
                     category: category,
                     isSelected: selectedCategory == category
                 )
                 .onTapGesture {
                     withAnimation {
                         selectedCategory = selectedCategory == category ? nil : category
                     }
                 }
             }
         }
         .padding(.horizontal)
     }
 }
}

struct CategoryPill: View {
 let category: GoalCategory
 let isSelected: Bool
 
 var body: some View {
     HStack {
         Image(systemName: category.systemImage)
         Text(category.rawValue)
     }
     .padding(.horizontal, 16)
     .padding(.vertical, 8)
     .background(isSelected ? Color.blue : Color(.systemGray5))
     .foregroundColor(isSelected ? .white : .primary)
     .cornerRadius(20)
 }
}*/



