//
//  LandMArksApp.swift
//  LandMArks
//
//  Created by Arihant Marwaha on 02/12/24.
//

import SwiftUI

@main
struct LandMArksApp: App {
    @State private var modelData = ModelData()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)
        }
    }
}
