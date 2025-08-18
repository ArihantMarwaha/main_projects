import Foundation
print("Hello")

//basic function call

func pro(){
    print("Hello world")
}
//function with parameters
func pros(name: String){//parmeter is a let and cant be mutated
    print("Hello \(name)")
}
pros(name: "Arihant")
//function with a reutrn value
func ret()->String{
    return "Arihant"
}
var name = ret()
print(name)
// Function with default parameters
func greet(name: String = "World") {
    print("Hello, \(name)!")
}
greet()
greet(name: "Vansh")

//intermediate


//external and internal parameter names
func greet(to name: String, from sender: String) {
    print("Hello \(name), from \(sender)")
}
greet(to: "John", from: "Jane")

//namespace removal with _
func hola(_ name : String){
    print("Hello \(name)")
}

hola("Arihant")

//vardic parameters useage
func greetu(names: String...) {
    for name in names {
        print("Hello, \(name)!")
    }
}

greetu(names: "Arihant","Vansh","Polymorph")



