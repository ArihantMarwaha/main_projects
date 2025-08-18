import Foundation


var koop = [23,45,67,88,5]

func divide(num: Int,div : Int )-> Float {
    
    guard div != 0 else{
        print("the given number is invalid for division")
        return 0
    }
    let result : Float = (Float)(num)/(Float)(div)
    
    return result
    
}

let floora : Float = divide(num: 56, div: 5)

print(floora)

func flowers(bow : Int?, crow : String? , book : Bool?) {
    
    guard let hole = bow,
          let brow = crow,
          let yapp = book else {return}
    
    
    print("\(hole) is reason why \(crow) will become \(yapp) and cause you to lose your virginiry")
}

flowers(bow: 69, crow: "AIDS monkey", book: true)

enum holygrail{
    case north,east,west,south
}

var holy  = holygrail.north

print(holy)

