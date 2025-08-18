import Cocoa
import SwiftUI

var greeting = "Hello, playground"

print(greeting)

let holo = "hello"

//this is a comment

/*
 this is a longer comment
 and it can go on for multiple lines as such
*/

struct perosn{
    var name:String
    let age:Int
    func sayhello(){
        print("this is a greeting that says \(greeting) and you are \(name) of age \(age)")
    }
}

var yolo = perosn(name:"arihant", age:19)

yolo.sayhello()
yolo.name = "not arihant"
yolo.sayhello()


//interval mathcing in switch case statements

var yo = 90


    
    switch yo{
    case 0...30:
        print("\(yo)number lies between 0 and 30")
    case 31...60:
        print("\(yo)number lies between 31 and 60")
    case 61...90:
        print("\(yo)number lies between 61 and 90")
    default:
        print("this number lies above 91")
    }
    


//string functions


var name  = "Arihant"
var hoop = "basketball"

hoop = "football"

var para = """
\"this is \t a multi\"\n
\"line paragraph\"
"""



print(name)

print(hoop)

print(para)

var po = ""

if po.isEmpty{
    print("this string is empty")
}


var olo :String = " Marwaha"
var goop :Character
var poop :Character

goop = "a"

print(olo)
print(goop)

let concat :String = name+olo
print(concat)

var hola = name+olo
name+=olo
print(hola)
print(name)

let groom = "Honey Singh"
let album = "Vol1"
let bride = "Annanya Pnadey"

print("\(album) is one of the most popular songs of \(groom)back in the day when he was still a low life arist")

if groom == bride{
    print("your boi gay")
}else{
    print("\(groom) is the groom of the lovely \(bride)")
}

let a = 5
let b = 6

print("if a is \(a) and b is \(b) then a+b = \(a+b)")

var comb = "ComB"
var cob = "CoB"
print(comb)
print(comb.lowercased())
print(comb.uppercased())

if comb.lowercased() == "cOMb".lowercased(){
    print("both strings are equal")
}
var sent = "hello! , World!"


if sent.hasPrefix("hello!") {
    print(sent.hasPrefix("hello!"))
    
}

if sent.hasSuffix("World!"){
    print(sent.hasSuffix("ld!"))
}

if(sent.hasSuffix("world!")){
    print(sent.hasSuffix("world!"))
}else{
    print(sent.hasSuffix("world!"))
}

if sent.contains("hello! ,"){
    print("this was a sucessful test")
}else{
    print("this was a bad example of Contains function")
}

//get the word count
var count = sent.count
print("the word count of the sent variable is :- \(count)")

var bol = "a"

switch bol{
case "a","e","i","o","u":
    print("this character is a vowel")
default:
    print("this character is a consonent")
}


/*
startIndex
endIndex
index(before:)
index(after:)
index(_:offsetBy:)
insert(_:at:)
insert(contentsOf:at:)
remove(at:)
removeSubrange(_:)
replaceSubrange(_:with:)
*/
print("🐮")

//function decleration
func vodoo(val:String){
    print("the value of the foloowing argument is \(val)")
}
vodoo(val:"arihant")

func rope(to person:String,and secondperson:String){
    
    print("A very happy birthday to the students \(person) and \(secondperson) for achiving this accolade that grants them 5000 units")
    
}

rope(to:"Ariant",and:"Milandeep")

//ommition of a function label

func spellcount(_ groom : String, age: Int){
    print("The doctor of age \(age) whose name is \(groom) was sucessful in carrying out the operation")
}
spellcount("Arihant", age: 19)

//deafualt func values

func def(age: Int,_ name : String="Arihant"){
    print("Age : \(age) \nName: \(name)")
}
def(age:19)

//return values
func addition(_ num1:Int,_ num2:Int)->Int{
    return (num1+num2)
}

var adds = addition(3,5)

print(adds)

//structures

struct car{
    var make : String
    var model : String
    var year : Int
    var topSpeed : Int
    
    func start(){
        print("The \(model) made by \(make) in year \(year) has started")
    }
    
    func drive(){
        print("The \(year) \(make) \(model) is moving")
    }
}
    
    let fitcar = car(make: "Honda", model: "Civic", year: 2004, topSpeed: 200)

fitcar.start()
fitcar.drive()
    

//initialisers
struct initialsers{
    
    //normal initialisers
    var glow = String.init()//""
    var blow = Int.init()//0
    var hope = Bool.init()//false
    
    //shorthand initailaisers
    var gone = String()//""
    var fool = Int()//0
    var tone = Bool()//false
    
    //default values
    var troop : Int  = 500
    var luhar : String = "hanta"
    var birth : Bool = true
}

var hole = initialsers()

print(hole)//prints the entire key data pair values of the given structure
var bole = initialsers(fool:609,birth:false)
print(bole)

//custom initialisers

struct temp{
    var celcius : Float
    
    init(celcius:Float){
        self.celcius = celcius
    }
    
    init(farhenite:Float){
        celcius = (farhenite-32)/1.8
    }
}

let celc = temp(celcius: 500)
let farc = temp(farhenite: 432)
print(farc.celcius)

//instance methods

struct Volume {
    var tops:Double = 0.0
    var sides:Double = 0.0
    var bottoms:Double = 0.0
    
    func vol()->Double{
        tops*sides*bottoms //shorthand return func
    }
    
    func shade()->Double{
        return tops*sides
    }
}

let squard = Volume(tops:40,sides:40,bottoms:40)
print(squard.vol())
print(squard.shade())

//mutating function
//acts like a static functions
struct doo{
    var count : Int = 0
    
    mutating func incri(){
        count += 1
        print(count)
    }
    
    mutating func balle(by amount: Int){
        count += amount
        print(count)
    }
    
    mutating func reset(){
        count = 0
        print(count)
    }
}

var dolo = doo()
dolo.incri()
dolo.balle(by:20)
dolo.incri()
dolo.incri()
dolo.incri()
dolo.incri()
dolo.incri()
dolo.reset()
dolo.incri()
dolo.incri()
dolo.incri()
dolo.incri()

//computed properties

struct temper{
    var cel:Double
    var far:Double{
        cel*1.8+32
    }
    var kev:Double{
        cel+273.15
    }
}

var delhi = temper(cel:35)
print("Celcius: \(delhi.cel)")
print("Farhen: \(delhi.far)")
print("Kelvin: \(delhi.kev)")

//property obervers
struct steps{
    var totalstrps : Int = 0{
        willSet{
            print("this is the initial value: \(newValue)")
        }
        didSet{
            if totalstrps > oldValue{
                print("this is the old value: \(oldValue)")
            }
        }
    }
}
var chomu = steps(totalstrps: 50)
chomu.totalstrps = 60

//static variables
struct tam{
    static var boil : Int  = 100
}
var gol = tam.boil
print(gol)
var vols = tam()
tam.boil+=50
print(tam.boil)

//copy an opjects values
struct jobs{
    var tool : Int
    var bol :  String
    var focus : Bool
}

var arihant = jobs(tool: 50, bol: "Arihant", focus: false)
var dhruv = arihant
arihant.focus = true
print(arihant.focus)
print(dhruv.focus)

struct hope {
    var color : Color = .red
    var description : String{
        return "This is an instancd of self \(self.color)"
    }
}
var trope = hope(color: .black)
var desc = trope.description

print(desc)

//classes and objects
class loopd {
    var goop : Int
    var hoopg : String
    var joke : Bool
    
    init(goop: Int, hoopg: String, joke: Bool) {
        self.goop = goop
        self.hoopg = hoopg
        self.joke = joke
    }
}

var role = loopd(goop: 56,hoopg: "hoop",joke: true)
var trys = role


//referencing the instances so they both use the same data
role.goop += 1
print(role.goop)
print(trys.goop)

//arrays

var fork = [44,32,21,45,32,56]
fork.sort()
print(fork)

var uto : Int = 0

for uto in fork{
    print(uto)
}



print(greeting )

struct books{
    var name : String?
//declaring an optional
    var year : Int?
}

let book1 = books(name: "holly", year: 2004)
let book2 = books(name: "bolly", year: 2005)
let book3 = books(name: "rolly", year: 2006)

let book = [book1,book2,book3]

//nil value acceptance
/*

var tool : Int? = 500
tool = nil
print(tool!)
*/
let unannounced = books(name: "Anon", year: nil)
var top : Any = 500
top = "holy"
print(top)

//optional binding

if let google = unannounced.year{
    print(google)
}else{
    print("this vaalue was not assigned")
}

func texts(url: URL) -> String?{
    return "holly"
}


struct Toll {
    var name : String
    var age : Int
    
    
  //failable initialisers
    init?(name: String, age: Int) {
        
        if age < 18 || age > 30 {
            return nil
        }else{
            self.name = name
            self.age = age
        }
        
    }
    
}

let manny = Toll(name: "Arihant", age: 15)

/*if let noob = manny{
    print("\(manny?.name) is the name , and \(manny?.age) is the age")
}else{
    print("the initialised value provided is not valid as it is less than 18 or more than 30")
}
*/

//optional chaining

struct personn{
    var hotel : String
    var resi : Residence?
}

struct Residence{
    var addr : Address?
}

struct Address{
    var street : String?
    var housenum : Int?
    var youth : Bool?
}




