import Foundation

struct CustomAuthModelItemError: LocalizedError {
    let itemIdentifier: String
    var errorDescription: String?
}
