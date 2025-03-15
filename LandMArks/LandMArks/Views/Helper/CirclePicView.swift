//
//  CirclePicView.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import SwiftUI


struct CirclePicView: View {
    var image: Image


    var body: some View {
        image
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 5)
    }
}


#Preview {
    CirclePicView(image: Image("turtlerock"))
}
