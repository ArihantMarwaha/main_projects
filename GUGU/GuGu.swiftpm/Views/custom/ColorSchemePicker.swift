//
//  SwiftUIView.swift
//  Planner port
//
//  Created by Arihant Marwaha on 21/01/25.
//

import SwiftUI

struct ColorSchemePicker: View {
    @Binding var selection: GoalColorScheme
    
    var body: some View {
        Picker("Color Scheme", selection: $selection) {
            ForEach(GoalColorScheme.allCases, id: \.self) { scheme in
                HStack {
                    Circle()
                        .fill(scheme.primary)
                        .frame(width: 20, height: 20)
                    Text(scheme.rawValue.capitalized)
                }
                .tag(scheme)
            }
        }
    }
}

// Preview
struct ColorSchemePicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            ColorSchemePicker(selection: .constant(.blue))
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Color Scheme Picker")
    }
}
