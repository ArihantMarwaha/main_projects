//
//  viewmodel .swift
//  practice protocols
//
//  Created by Arihant Marwaha on 06/08/25.
//

import Foundation
import SwiftUI
import Combine

class busi : ObservableObject{
    
    @Published var buss : [business] = []
    
    func fetchdata(){
        
        buss = [business(id: UUID(), name: "Arihant", email: "arihantmarwaha@gmail.com", phone: 8894071534),
                business(id: UUID(), name: "tanahira", email: "holabola@gmail.com", phone: 9816443239),
                business(id: UUID(), name: "Vansh", email: "vanshmrhra@gmail.com", phone: 8839393933 )]
    }
    
}
