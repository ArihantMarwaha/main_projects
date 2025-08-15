//
//  Showme.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 06/08/25.
//

import SwiftUI

struct Showme: View {
    
    @StateObject var goal = busi()
    
    var body: some View {
        NavigationView{
            List(goal.buss){
                user in
                
                VStack(alignment:.leading){
                    
                    Text(user.name).font(.title)
                    Text(user.email).fontWeight(.bold)
                }
            }
        }
        .navigationTitle("HOLA BOLA")
        .onAppear{
            goal.fetchdata()
        }
    }
}

#Preview {
    Showme()
}
