//numbers range
for x in 0...10{
    print(x)
}
//string
for ct in "Arihant"{
    print(ct)
}
//array
var toy = [1,23,45,32,32,56,76]
for gol in toy{
    print(gol)
}

//enumerated
var tray = "BOOOOOOOOOBS".enumerated()
print(tray)

for (t,u) in "BOOOOOOOOOOBIES".enumerated(){
    print("\(t+1) : \(u)")
}

//dicts
var rory = ["dolly":99,"Bolly":34,"Food":43]

for (key,val) in rory{
    print("\(key) : \(val)")
}

var i : Int = 0

//while loop
while i  < 10 {
    print(i)
    i+=1
}
print(i)

//repeat while loop 
repeat{
    print("GOT printed once")
}while i < 10

//see the difference
for i in -3...3{
    
    if i == 0{
        break
    }
    print(i)
}

//observe
for i in -3...3{
    print(i)
    if i == 0{
        break
    }
}

//continue

var hoops = [12,43,22,5,67,43,87]

for i in hoops {
    if i < 18 {
        continue
    }
    print("your age is \(i)")
}

