//
//  ToDolistViewModel.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 07/08/25.
//

import Foundation
import SwiftUI
import Combine

class ToDolistViewModel : ObservableObject {
    
    @Published var listitem : [todolistitem] = [
        todolistitem(title: "Maths", iscompleted: false),
        todolistitem(title: "Science", iscompleted: true),
        todolistitem(title: "SST", iscompleted: true),
        todolistitem(title: "Computer", iscompleted: true),
    ]
    
    func addTodo(title : String){
        let newitem = todolistitem(title: title, iscompleted: false)
        listitem.append(newitem)
    }
    
    func toggleDone(for item : todolistitem){
        if let index = listitem.firstIndex(of: item){
            listitem[index].iscompleted.toggle()
        }
        
    }
    
    func deleteTodo(at offsets: IndexSet){
        listitem.remove(atOffsets: offsets)
    }
    
    
}
