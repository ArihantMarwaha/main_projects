//: [Previous](@previous)

import Foundation


struct hope : Equatable, Codable{
    var tor : String
    var bol : String
    var yol : Int
    var dol : Bool
    
    static func == (lhs : hope , rhs  : hope)-> Bool{
        return lhs.yol == rhs.yol
    }
}



let gool = hope(tor: "Torr", bol: "ore", yol: 69, dol: true)
let gol = hope(tor: "Porr", bol: "Store", yol: 9, dol: true)
let goo = hope(tor: "sorr", bol: "Seed", yol: 39, dol: false)
let ool = hope(tor: "rope", bol: "Proune", yol: 22, dol: true)


var gop = [gool,gol,ool,goo]

var foat = gop.sorted(by: ==)

for jo in foat{
    print(jo)
}

let jasonEncoder = JSONEncoder()

if let nore =  try? jasonEncoder.encode(gool),let boreString = String(data: nore, encoding: .utf8){
    
    print(boreString)
    
}

//custom protocols

protocol saurab {
    var good : String { get }
    
    func fun()
}

struct node : saurab {
    
    var trap : String
    var fort : Int
    
    //protocols addition
    
    var good : String {
        return "Trap : \(trap) and Fort : \(fort)"
    }
    
    func fun(){
        print(good)
    }
}

var tool = node(trap: "Mouse", fort: 66)

tool.fun()

