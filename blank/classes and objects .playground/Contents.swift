import UIKit
import Foundation

//structure
struct person {
    var name : String
    var age : Int
    var email : String
    
    init(name: String, age: Int, email: String) {
        self.name = name
        self.age = age
        self.email = email
    }
}

var g = person(name: "Arihant",age: 20, email: "arihantmarwaha@gmail.com")
print(g)

//class
class Vehicle {
    var speed = 0
    func accelerate() {
        speed += 10
    }
}

var car = Vehicle()
car.accelerate()
car.speed

struct pop{
    var id : UUID
    
    init(id: UUID) {
        self.id = id
    }
}

