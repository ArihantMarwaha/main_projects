//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let colorScheme: GoalColorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 5)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(colorScheme.gradient, style: StrokeStyle(
                    lineWidth: 5,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(-90))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.8), value: progress)
    }
}
