//
//  Todomodel.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 07/08/25.
//

import Foundation

struct todolistitem : Hashable , Identifiable{
    let id : UUID = UUID()
    var title : String
    var iscompleted : Bool
}
