import Foundation

/// Data Transfer Object for parsing mock feeding points from JSON
struct MockFeedingPointsResponse: Codable {
    let feedingPoints: [MockFeedingPoint]
}

struct MockFeedingPoint: Codable {
    let id: String
    let location: Location
    let status: String
    let category: String

    struct Location: Codable {
        let lat: Double
        let lon: Double
    }
}
