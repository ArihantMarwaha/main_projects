@propertyWrapper
struct Uppercased {
    private var value: String

    var wrappedValue: String {
        get { value }
        set { value = newValue.uppercased() }
    }

    init(wrappedValue: String) {
        self.value = wrappedValue.uppercased()
    }
}

struct User {
    @Uppercased var name: String
}

var user = User(name: "john doe")
print(user.name)  // Output: "JOHN DOE"

user.name = "alice"
print(user.name)  // Output: "ALICE"

var t : String? = "ARIHANT"
print(t?.lowercased() ?? "Arihant")










