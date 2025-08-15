//
//  SwiftUIView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 14/08/25.
//

import SwiftUI

struct RecursivePatternView: View {
    let depth: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Step 1: Draw your base pattern
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Color.red
                        Color.blue
                    }
                    VStack(spacing: 0) {
                        Color.green
                        Color.yellow
                    }
                }
                
                // Step 2: Recursively place smaller versions inside
                if depth > 0 {
                    RecursivePatternView(depth: depth - 1)
                        .scaleEffect(0.5) // Make smaller
                        .offset(
                            x: geometry.size.width / 4,
                            y: geometry.size.height / 4
                        )
                }
            }
        }
    }
}

struct entView: View {
    var body: some View {
        RecursivePatternView(depth: 4) // Try changing depth
            .frame(width: 300, height: 300)
    }
}

#Preview{
    entView()
}
