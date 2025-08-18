enum FileError: Error {
    case fileNotFound
    case unreadable
    case unknown
}

func readFile(named fileName: String) throws -> String {
    if fileName.isEmpty {
        throw FileError.fileNotFound
    }
    return "File content"
}

do {
    let content = try readFile(named: "")
    print(content)
} catch FileError.fileNotFound {
    print("The file was not found.")
} catch {
    print("An unknown error occurred.")
}


//declaring an error
enum NetworkError: Error {
case noInternet
case serverError(code: Int)
case invalidURL
}

//throwing an error
func fetchData(from url: String) throws {
    guard url.starts(with: "https") else {
        throw NetworkError.invalidURL
    }
    // Fetch logic
}


//Handling Errors
do {
    try fetchData(from: "http://example.com")
} catch NetworkError.invalidURL {
    print("URL is invalid.")
} catch {
    print("Some other error: \(error)")
}
/*| Keyword | Behavior                                                       |
 | ------- | -------------------------------------------------------------- |
 | `try`   | Use in `do-catch`, rethrows error if uncaught                  |
 | `try?`  | Converts result to optional – returns `nil` if error is thrown |
 | `try!`  | Assumes no error will be thrown – **crashes if error occurs**  |
*/

let result1 = try? fetchData(from: "bad_url") // result1 = nil
let result2 = try! fetchData(from: "https://good.com") // OK if no error
