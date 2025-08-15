//
//  BasicsView\.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 22/07/25.
//

import SwiftUI

struct BasicsView: View {
    var body: some View {
        
        //text
        Text("Arihant Marwaha")
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundStyle(.indigo)
        
        //image
        Image(systemName: "star.fill") // SF Symbols
            .resizable()
            .frame(width: 50, height: 50)
            .foregroundColor(.yellow)
        
        //button
        Button("Tap Me") {
            print("Button tapped!")
        }
        .padding()
        .glassEffect(.regular)
        .foregroundColor(.green)
        .cornerRadius(30)
        
        //vertical stack <->
        VStack {
            Text("Top")
            Text("Middle")
            Text("Bottom")
        }

        //horizonatal stack top-bottom
        HStack {
            Text("Left")
            Spacer()
            Text("Right")
        }
        .padding(60)

        //Zstack
        ZStack {
            Color.indigo
            Button("Tap Me") {
                print("Button tapped!")
            }
            .padding()
            .glassEffect(.clear)
            .foregroundColor(.white)
            .cornerRadius(30)

        }
        .frame(width: 90, height: 50)
        

        
        
        
    }
}

#Preview {
    BasicsView()
}
