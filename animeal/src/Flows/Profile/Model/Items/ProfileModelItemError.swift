import Foundation

struct ProfileModelItemError: LocalizedError {
    let itemIdentifier: String
    var errorDescription: String?
}

struct ProfileModelItemAgeError: LocalizedError {
    let selected: Bool
}
