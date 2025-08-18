import Foundation
//basic data types
var a : String = "Arihant"
var b : Int = 10
var c : Data //Use Case: Storing raw JSON data from an API response
var d : Character = "D"
var e : Bool = true
var f : Float = 4.99
var g : Double = 3.9237278373

//array data types
var h : Array<Int> = [1,2,3,4,5,6,7,8,9,10] //array of elements
var i : Set<Int> = [101,102,103]//no duplicates
var j : Dictionary<Int,String> = [9: "Arihant",10:"Messi"]  //dictionary

//optionals
var k : Optional<Int>
k = nil

//Tuple :- combines multiple things into one
var l : (lose : String, win : String) = ("lose","Win")

//any:  var goal : Any = 1 , "Arihant" , true [anything]
var value: Any = "Hello"
value = 42
value = true

//enum
enum Direction {
    case north, south, east, west
}
let move = Direction.north
print(move)

//date
var date : Date = Date()
let components = Calendar.current.dateComponents([.day, .month,.year], from: Date())
let start = Date()
let end = start.addingTimeInterval(90) // 90 seconds later
let difference = end.timeIntervalSince(start) // 90.0


//URL
let website = URL(string: "https://apple.com")

//UUID
let id = UUID()
print("Unique ID: \(id)")

//if, else if
var top : Int = 15
if(top < 5){
    print("True")
}else if(top == 15){
    print("got it")
}else{
    print("False")
}

//switch
let direction = "north"

switch direction {
case "north":
    print("Go up")
case "south":
    print("Go down")
default:
    print("Unknown direction")
}

//switch with tuples
let point = (0, 0)

switch point {
case (0, 0):
    print("Origin")
case (_, 0):
    print("On X-axis")
case (0, _):
    print("On Y-axis")
default:
    print("Somewhere else")
}

//for in loop
for number in 1...5 {
    print("Number: \(number)")
}

//while loop
var count = 0

while count < 3 {
    print("Count is \(count)")
    count += 1
}

//repeat while loop
var number = 0

repeat {
    print("Repeating: \(number)")
    number += 1
} while number < 3

//continue and break
for i  in 1...5{
    print(i)
    if(i == 2){
        continue
    }else if(i == 3){
        break
    }
}

//for in where
for num in 1...10 where num % 2 == 0 {
    print("Even: \(num)")
}


//optionals
var total : Int? = nil

if let safe = total {
    print("the data is safe")
}else{
    print("the data is null")
}

//guard

func greet(_ name: String?) {
    guard let safeName = name else {
        print("No name provided")
        return
    }

    print("Hello, \(safeName)")
}

greet("Arihant")


func validate(_ age: Int) {
    guard age >= 18 else {
        print("Not allowed")
        return
    }
    print("Welcome!")
}

validate(20)
validate(10)

//nestedoptional checking
func processUser(name: String?, age: Int?) {
    // Early exit if name is nil
    guard let name = name else {
        print("Name is missing")
        return
    }

    print("Name: \(name)")

    // Optional age check using if let
    if let age = age {
        print("Age: \(age)")
    } else {
        print("Age is missing")
    }
}






