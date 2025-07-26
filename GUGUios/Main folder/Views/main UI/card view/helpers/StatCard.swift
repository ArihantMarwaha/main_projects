//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI


/*
 struct StatCard: View {
     let title: String
     let value: String
     let icon: String
     let color: Color
     
     var body: some View {
         VStack(alignment: .leading, spacing: 8) {
             HStack {
                 Image(systemName: icon)
                     .foregroundColor(color)
                 Text(title)
                     .foregroundColor(.gray)
             }
             .font(.subheadline)
             
             Text(value)
                 .font(.title2)
                 .bold()
         }
         .padding()
         .frame(maxWidth: .infinity, alignment: .leading)
         .background(color.opacity(0.1))
         .cornerRadius(10)
     }
 }

 */

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 25, weight: .bold))
            }
            Spacer()
        }
        .padding(.vertical, 13)
        .padding(.horizontal, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
}


