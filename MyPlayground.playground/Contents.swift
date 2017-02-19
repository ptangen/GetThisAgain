

// Classes
class Vehicle {
    var wheelCount: Int
    var passengerCount: Int
    
    init(wheelCount: Int, passengerCount: Int) {
        self.wheelCount = wheelCount
        self.passengerCount = passengerCount
    }
    
    convenience init() {
        self.init(wheelCount: 0, passengerCount: 0)
    }
    
    func addPassenger(count: Int) {
        self.passengerCount += count
    }
}
let myVehicle = Vehicle(wheelCount: 2, passengerCount: 1)
myVehicle.addPassenger(count: 2)
print(myVehicle.passengerCount)

// Subclasses

class Car: Vehicle {
    let seats: Int
    
    init(wheelCount: Int, passengerCount: Int, seats: Int) {
        self.seats = seats
        super.init(wheelCount: wheelCount, passengerCount: passengerCount)
    }
}

let myCar = Car(wheelCount: 4, passengerCount: 1, seats: 2)
myCar.addPassenger(count: 1)
print(myCar.passengerCount)

// Polymorphism
// The ability to define an object as an ancestor type and then cast it as the lower level type when needed.

let vehicle1: Vehicle, vehicle2: Vehicle

vehicle1 = Vehicle()
vehicle2 = Car(wheelCount: 6, passengerCount: 2, seats: 4)

let myVehicles = [vehicle1, vehicle2]


// Closures
// the last parameter is a a function named greeting. Anyone that uses this function must pass in a function of type (String) -> String
// the @escaping keyword means that the closure will still be around after the function completes. This is important for things like asynchrous requests. In the example below, @escaping has no effect.

func generateGreeting(place: String, greeting: @escaping (String) -> String) {
    print("My name is Jim from \(place)")
    let greetingForPerson = greeting("Jack")

    print("\(greetingForPerson)\n")         // call the other function here, must match the type specified in the signature
}

// calling the function in the long syntax
generateGreeting(place: "NH", greeting: {(person: String) -> String in
    return "Hello to you \(person)"
})

// calling the function in the condensed syntax
generateGreeting(place: "VT", greeting: {person in
    return "Hello to you \(person)"
})








