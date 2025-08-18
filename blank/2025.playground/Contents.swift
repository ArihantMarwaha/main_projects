import Foundation

var greeting = "Hello 2025"
print(greeting)


enum category : String{
    case food
    case drinks
    case electronics
    case tops = "Top"
}
var gol = category.food
var paint = category.tops

print(gol)
print(paint.rawValue)
