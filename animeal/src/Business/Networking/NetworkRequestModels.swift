import Foundation

struct StartFeeding: Codable {
    let startFeeding: String
}

struct CancelFeeding: Codable {
    let cancelFeeding: String
}

struct UpdateFeedingPoint: Codable {
    let id: String
}
