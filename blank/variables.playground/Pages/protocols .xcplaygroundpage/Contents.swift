//: [Previous](@previous)

//basic protocls used in the given file
//CustomStringConveertable - for printing out class objects and strings
//Equatable = comparison and checking Equal Objects
//Comparable = Comparing 2 objects
//Codable = encode and decode Multile data formats like JSON to and from one another 

import Foundation

var greeting = "Hello, playground"


//custom string convertable
class shoe : CustomStringConvertible{
    let color : String
    let size : Int
    let hasLaces : Bool
    
    init(color : String , size : Int , hasLaces : Bool){
        
        self.color = color
        self.size = size
        self.hasLaces = hasLaces
        
    }
    
    var description : String {
        return "Color : \(color), Size : \(size), Has laces : \(hasLaces)"
    }
}


var tool = shoe(color:"hello",size: 69, hasLaces: true)

print(tool)

//comparing information with equatable

struct Employee : Equatable {
    var Firstname : String
    var Lastname : String
    var JobTitle : String
    var Phone : Int
    
    static func ==(lhs : Employee, rhs : Employee) -> Bool{
        
        return lhs.Firstname == rhs.Firstname && lhs.Lastname == rhs.Lastname && lhs.JobTitle == rhs.JobTitle
        
    }
}

class Record {
    var name : String
    var employee : [Employee]
    
    init(name: String, employee: [Employee]) {
        self.name = name
        self.employee = employee
    }
}

//comparable

struct noble : Comparable{
    static func == (lhs: noble, rhs: noble) -> Bool {
        return lhs.ages == rhs.ages
    }
    
    
    
    var rope : String
    var hope : String
    var ages : Int
    
    init(rope: String, hope: String, ages: Int) {
        self.rope = rope
        self.hope = hope
        self.ages = ages
    }
        
    
    static func <(lhs: noble, rhs: noble)-> Bool{
        
        return lhs.ages < rhs.ages

    }
}


let gore = noble(rope: "Role", hope: "Pole", ages: 56)
let ore = noble(rope: "Nome", hope: "Dome", ages: 22)
let re = noble(rope: "Creet", hope: "Street", ages: 92)
let e = noble(rope: "Cr", hope: "reet", ages: 2)

var jome = [gore,ore,re,e]

let sortted = jome.sorted(by: ==)

for nob in sortted{
    print(nob)
}

//codabel protocol to use encode and decode functions which help us to save data on a pre run code once it terminates and runned again

struct hope : Equatable, Comparable, Codable{
    var tor : String
    var bol : String
    var yol : Int
    var dol : Bool
    
    static func < (lhs : hope , rhs  : hope)-> Bool{
        return lhs.yol < rhs.yol
    }
}



