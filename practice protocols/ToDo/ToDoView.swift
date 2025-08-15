//
//  ToDoView.swift
//  practice protocols
//
//  Created by Arihant Marwaha on 07/08/25.
//

import SwiftUI

struct ToDoView: View {
    
    @StateObject var todos = ToDolistViewModel()
    @State var newTodoTitle : String = ""
    
    var body: some View {
        NavigationStack {
            
            VStack{
                
                HStack{
                    TextField("New todo", text:$newTodoTitle)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 200,alignment:.topLeading)
                    
                    Button("Add"){
                        guard !newTodoTitle.isEmpty else{
                            print("Invalid title")
                            return
                        }
                        todos.addTodo(title: newTodoTitle)
                        newTodoTitle = ""
                        print(newTodoTitle)
                    }
                }
                .padding()
                
                List{ ForEach(todos.listitem){ todo in
                    
                    HStack{
                        Text(todo.title)
                        Spacer()
                        Button{
                            
                            todos.toggleDone(for: todo)
                            
                            
                        } label: {
                            Image(systemName: todo.iscompleted ? "checkmark.circle.fill" : "circle",)
                        }
                        
                      
                    }
                    
                }
                .onDelete(perform: todos.deleteTodo(at: ))
                    
                }
                
            }
            
        }
    }
}

#Preview {
    ToDoView()
}
