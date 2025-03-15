//
//  ContentView.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var selection: Tab = .featured
    
    enum Tab {
           case featured
           case list
       }
    
    
    var body: some View {
        TabView(selection: $selection) {
                    CategoryHome()
                .tabItem {
                                   Label("Featured", systemImage: "star")
                               }
                        .tag(Tab.featured)
            LandmarkList()
                .tabItem     {
                                    Label("List", systemImage: "list.bullet.circle.fill")
                        
                        
                                }
                
                .tag(Tab.list)
                }
    }
       
}

#Preview {
    ContentView()
        .environment(ModelData())
}
