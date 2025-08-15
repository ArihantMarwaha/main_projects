//
//  SwiftUIView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 14/08/25.
//

import SwiftUI


struct concerntic {
    var n : Int
}

class paterns{
    var box : Color
    var size: Int = 0
    
    init(box: Color, size: Int) {
        self.box = box
        self.size = size
    }
}



struct SwiftUIView: View {
    var body: some View {
       
        @State var pat = [paterns].self
        
        
        
    }

}

#Preview {
    SwiftUIView()
}
