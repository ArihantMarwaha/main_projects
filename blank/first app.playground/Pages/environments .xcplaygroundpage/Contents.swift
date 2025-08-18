//: [Previous](@previous)

import Foundation



//: [Next](@next)

func greet(user : String?) {
    
    guard let users = user else{
        print("The user was invalid")
        return
    }
    print("hello \(users)")
}

greet(user: "Ari")
greet(user: nil)


func greetUser(user: String?) {
    guard let userName = user else {
        print("No user to greet!")
        return
    }
    print("Hello, \(userName)!")
}

greetUser(user: "Alice") // Output: Hello, Alice!
greetUser(user: nil)
