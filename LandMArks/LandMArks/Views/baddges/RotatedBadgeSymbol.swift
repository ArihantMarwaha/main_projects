//
//  RotatedBadgeSymbol.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 03/01/25.
//

import SwiftUI


struct RotatedBadgeSymbol: View {
    let angle: Angle
    
    var body: some View {
        BadgeSymbol()
            .padding(-60)
            .rotationEffect(angle, anchor: .bottom)
    }
}


#Preview {
    RotatedBadgeSymbol(angle: Angle(degrees: 20))
}
