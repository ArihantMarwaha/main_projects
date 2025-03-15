//
//  CategoryHome.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 06/01/25.
//

import SwiftUI

struct CategoryHome: View {
    // create a modelData property
    @Environment(ModelData.self) var modelData
    @State private var showingProfile = false
    
    var body: some View {
        
        NavigationSplitView {
            
            List{
                
                modelData.features[2].image
                                   .resizable()
                                   .scaledToFill()
                                   .frame(height: 200)
                                   .clipped()
                //Set the edge insets to zero on both kinds of landmark previews so the content can extend to the edges of the display.
                                   .listRowInsets(EdgeInsets())
                
                ForEach(modelData.categories.keys.sorted(),id: \.self){
                    key in  CategoryRow(categoryName: key, items: modelData.categories[key]!)
                }
                .listRowInsets(EdgeInsets())
            }
            .listStyle(.inset)
            .navigationTitle("Featured")
            
            // toolbar modifier, and present the ProfileHost view when the user taps it.
            .toolbar {
                            Button {
                                showingProfile.toggle()
                            } label: {
                                Label("User Profile", systemImage: "person.crop.circle")
                            }
                        }
            //pop up animation .sheet
                        .sheet(isPresented: $showingProfile) {
                            ProfileHost()
                                .environment(modelData)
                        }
        } detail: {
            Text("Select a Landmark")
        }
        
    }
}

#Preview {
    CategoryHome()
        .environment(ModelData())
}
