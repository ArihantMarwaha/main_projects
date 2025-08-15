//
//  ToggleView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 22/07/25.
//

import SwiftUI
import Combine

struct ToggleView: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Enabled", isOn: $isOn)
    }
}


struct ParentView: View {
    
    //state variable is a local variable
    @State private var isSwitchOn = false
    
    //ObservedObject is used for external data models that conform to ObservableObject
    @ObservedObject var tim = timemodel()
    
    @StateObject var time = timemodel()

    var body: some View {
        ToggleView(isOn: $isSwitchOn)
        Text("Time: \(tim.times)")
        Text("Time: \(time.times)")
    }
}


class timemodel : ObservableObject{
    @Published var times = 0
}



