import SwiftUI
protocol Greetable {
    func greet()
}

struct Person: Greetable {
    func greet() {
        print("Hello!")
    }
}

//Protocol with Properties
protocol Named {
    var name: String { get }
}

struct User: Named {
    var name: String
}
print(User(name: "Arihant"))

//Protocol with Methods
protocol Payable {
    func calculateWages() -> Int
}

// Mutating Methods (for structs/enums)
protocol Resettable {
    mutating func reset()
}

struct Counter: Resettable {
    var value = 0

    mutating func reset() {
        value = 0
    }
}

//Initializers in Protocols
protocol Initializable {
    init(name: String)
}

class Employee: Initializable {
    required init(name: String) {
        // required because of subclassing
    }
}

//Protocol Inheritance
protocol Animal {
    func eat()
}

protocol Pet: Animal {
    func play()
}


//Built-in Swift Protocols

//Equatable
//Used to check if two values are equal (==).
struct ser: Equatable {
    let name: String
    let id: Int
}

let u1 = ser(name: "Arihant", id: 1)
let u2 = ser(name: "Ariha", id: 1)
let u3 = ser(name:"Arihant",id: 2)
let u4 = ser(name: "Arihant", id: 1)

print(u1 == u2)//false
print(u1 == u3)//false
print(u1 == u4)//true


//Comparable
//Used to compare values (<, >, <=, >=) and sort them.
struct Score: Comparable {
    let value: Int

    static func < (lhs: Score, rhs: Score) -> Bool {
        return lhs.value < rhs.value
    }
}

let scores = [Score(value: 10), Score(value: 5), Score(value: 20)]
let sorted = scores.sorted() // Sorted ascending



//Hashable
//Allows use in Set or as keys in Dictionary.
struct Book: Hashable {
    let title: String
}

let book1 = Book(title: "Swift Mastery")
let book2 = Book(title: "Swift Mastery")
let book3 = Book(title: "Arihant")

let set: Set = [book1, book2,book3] // Only one copy due to hashable

let dict: [Book: Int] = [book1: 1,book3:3]


//Codeable
//for encoding and decoding data
struct Profile: Codable {
    let name: String
    let age: Int
}

let profile = Profile(name: "Arihant", age: 23)
let jsonData = try JSONEncoder().encode(profile)
let decoded = try JSONDecoder().decode(Profile.self, from: jsonData)


//CustomStringConvertible
//Customizes the .description property for printing.
struct City: CustomStringConvertible {
    let name: String
    let home: String
    
    var description: String {
        return "City is \(name) and I live in \(home)"
    }
}

print(City(name: "Delhi",home: "Palampur")) // Output: City is Delhi

//CaseIterable
//Used with enums to get all cases as an array
enum Direction: CaseIterable {
    case north, south, east, west
}

print(Direction.allCases) // [north, south, east, west]

/*
 //identifiable
 //creates id for the use with SwiftUI/Combine.
 struct Task: Identifiable {
     let id: UUID
     let title: String
 }

 let t = Task(id: UUID(), title: "Finish Swift")

*/







