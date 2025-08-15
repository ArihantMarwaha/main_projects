//
//  listView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 22/07/25.
//

import SwiftUI

struct listView: View {
    var body: some View {
        
        //list
        
        HStack{
            let fruits = ["Apple", "Banana", "Cherry"]
            
            List(fruits, id: \.self) { fruit in
                Text(fruit)
            }
            Spacer()
            //scrollview
            ScrollView {
                VStack {
                    ForEach(1...50, id: \.self) { i in
                        Text("Item \(i)")
                    }
                }
            }
            
        }
        
        
        
        
    }
}

#Preview{
    listView()
}

struct hoops : View {
    
    var body: some View{
        
        
            
                Text("Hello, Arihant!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading,-150)
            
            

                
                let top : [String] = ["Adoom SUD","Arihant","Vansh","Muskan","Amaan","Milan","Dhruv","Sadhav"]
                
                
                List(top, id: \.self){
                    item in Text(item)
                }
        
 
        ZStack() {
                   
                   // 🔴 Fixed red bar background
            Image("pool")
                .resizable()
                               .scaledToFill()
                               .frame(width: 300) // Adjust width as needed
                               .clipped()
                               .ignoresSafeArea()
                
                // Covers entire height
                   
                   // 🧾 Scrollable content (buttons) on top
                   ScrollView {
                       
                          
                               Button("Tap Me") {
                                   print("Button tapped!")
                               }
                               .padding()
                               .foregroundColor(.white)
                               .glassEffect(.clear.interactive())
                               .cornerRadius(20)
                       
                       Button("Tap Me") {
                           print("Button tapped!")
                       }
                       .padding()
                       .foregroundColor(.black.opacity(0.2))
                       .glassEffect(.regular.interactive())
                       .cornerRadius(20)
                       
                       
                           
                       
                       .padding() // Shift buttons right of red bar
                       .padding(.vertical, 10)
                   }
               }
      
        
        
   
        
                
            

        
    }
    
}

#Preview {
   hoops()
}

/*
 Modifier    Description
 .font()    Sets font style
 .foregroundColor()    Changes text or shape color
 .padding()    Adds padding inside view
 .background()    Adds background view or color
 .frame()    Sets width/height
 .cornerRadius()    Rounds corners
 .opacity()    Changes transparency
 .onTapGesture()    Adds tap handler
 .shadow()    Adds shadow effect
 */
