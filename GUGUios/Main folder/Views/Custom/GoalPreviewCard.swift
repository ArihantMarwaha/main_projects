//
//  GoalPreviewCard.swift
//  GUGUios
//
//  Created by Arihant Marwaha on 29/06/25.
//

import SwiftUI

struct GoalPreviewCard: View {
    let template: CustomGoalTemplate
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(template.title.isEmpty ? "Goal Title" : template.title)
                        .font(.headline)
                        .foregroundColor(template.title.isEmpty ? .secondary : .primary)
                    
                    Spacer()
                    
                    Text("\(template.targetCount)×")
                        .foregroundColor(.secondary)
                }
                
                if !template.description.isEmpty {
                    Text(template.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label("\(template.intervalHours, specifier: "%.1f") hours",
                          systemImage: "clock")
                    Spacer()
                    Circle()
                        .fill(template.colorScheme.primary)
                        .frame(width: 20, height: 20)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
        .buttonStyle(PlainButtonStyle())
    }
}

//preview function
struct GoalPreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        GoalPreviewCard(
            template: CustomGoalTemplate(
                title: "Hydration Goal",
                description: "Drink 8 glasses of water daily",
                targetCount: 8,
                intervalHours: 2.0,
                colorScheme: .blue
            ),
            onTap: { print("Goal tapped") }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
