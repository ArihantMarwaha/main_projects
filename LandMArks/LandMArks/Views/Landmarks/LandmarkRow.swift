//
//  LandmarkRow.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import SwiftUI

struct LandmarkRow: View {
    var landmark : Landmark
    var body: some View {
        
        HStack{
            landmark.image
                .resizable()
                .frame(width:50,height: 50)
                
            Text(landmark.name)
            
            Spacer()
            
            if landmark.isFavorite {
                            Image(systemName: "bookmark.fill")
                    .foregroundStyle(.yellow)
                        }
                
            
        }
    
    }
}

#Preview("TurtleRock") {
    let landmarks = ModelData().landmarks
    Group{
        LandmarkRow(landmark:landmarks[0])
        LandmarkRow(landmark:landmarks[1])
        
    }
   
}


