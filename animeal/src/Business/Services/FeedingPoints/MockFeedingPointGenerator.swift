import Foundation
import Amplify

enum MockFeedingPointGenerator {
    private static let cities = ["Central District", "North Park", "East Side", "West End", "South Valley"]

    private static let streetPrefixes = ["St.", "Ave.", "Blvd.", "Sq.", "Rd."]

    private static let streetNames = [
        "Main", "Oak", "Maple", "Park", "Hill",
        "River", "Lake", "Forest", "Garden", "Meadow"
    ]

    private static let names = [
        "Near Metro Station", "Park Area", "Town Square",
        "School Area", "Central Square", "Market Place", "Bus Station",
        "Park Entrance", "Shopping Center", "Community Center"
    ]

    private static let descriptions = [
        "Quiet place for feeding animals",
        "Popular spot with regular visitors",
        "Needs regular care",
        "New feeding point",
        "Several stray animals here",
        "Peaceful location, rarely visited",
        "Near shopping center, easy to find",
        "In park area",
        "Close to residential area",
        "Accessible location"
    ]

    private static let cityCoordinates: [String: (lat: Double, lon: Double)] = [
        "Central District": (41.7151, 44.8271),
        "North Park": (41.6168, 41.6367),
        "East Side": (42.2679, 42.6941),
        "West End": (41.5495, 45.0000),
        "South Valley": (41.9847, 44.1089)
    ]

    static func generateMockFeedingPoints(count: Int = 15) -> [FullFeedingPoint] {
        var points: [FullFeedingPoint] = []

        for i in 0..<count {
            let point = generateSinglePoint(index: i)
            points.append(point)
        }

        return points
    }

    static func generateSinglePoint(index: Int) -> FullFeedingPoint {
        let city = cities[index % cities.count]
        guard let baseCoordinates = cityCoordinates[city] else {
            fatalError("City coordinates not found for city: \(city)")
        }

        let latOffset = Double.random(in: -0.05...0.05)
        let lonOffset = Double.random(in: -0.05...0.05)

        let lat = baseCoordinates.lat + latOffset
        let lon = baseCoordinates.lon + lonOffset

        guard let streetPrefix = streetPrefixes.randomElement(),
              let streetName = streetNames.randomElement() else {
            fatalError("Failed to generate street name")
        }

        let buildingNumber = Int.random(in: 1...100)
        let street = "\(streetPrefix) \(streetName), \(buildingNumber)"

        let name = names[index % names.count]
        let description = descriptions[index % descriptions.count]

        let status: FeedingPointStatus
        switch index % 3 {
        case 0: status = .starved
        case 1: status = .fed
        default: status = .pending
        }

        let now = Temporal.DateTime.now()

        // Alternate between cats and dogs
        let categoryTag: CategoryTag = index % 2 == 0 ? .cats : .dogs
        let category = Category(
            id: "mock-category-\(categoryTag.rawValue)",
            name: categoryTag == .cats ? "Cats" : "Dogs",
            icon: categoryTag == .cats ? "cat-icon" : "dog-icon",
            tag: categoryTag,
            i18n: nil,
            createdAt: now,
            updatedAt: now,
            createdBy: nil,
            updatedBy: nil,
            owner: "mock-owner"
        )

        let feedingPoint = FeedingPoint(
            id: "mock-fp-\(UUID().uuidString)",
            name: name,
            description: description,
            city: city,
            street: street,
            address: "\(city), \(street)",
            images: generateImageKeys(count: Int.random(in: 1...3)),
            point: Point(type: "Point", coordinates: [lon, lat]),
            location: Location(lat: lat, lon: lon),
            region: city,
            neighborhood: "\(city) district",
            distance: Double.random(in: 0.5...10.0),
            status: status,
            i18n: nil,
            statusUpdatedAt: now,
            createdAt: now.add(value: -Int.random(in: 1...30), to: .day) ?? now,
            updatedAt: now,
            createdBy: "mock-user-\(Int.random(in: 1...5))",
            updatedBy: "mock-user-\(Int.random(in: 1...5))",
            owner: "mock-owner",
            pets: [],
            category: category,
            users: [],
            cover: generateCoverImageKey(),
            feedingPointCategoryId: category.id
        )

        let isFavorite = index % 4 == 0

        return FullFeedingPoint(
            feedingPoint: feedingPoint,
            isFavorite: isFavorite,
            imageURL: nil
        )
    }

    static func generateMockFeedingHistory(
        for feedingPointId: String,
        count: Int = 5
    ) -> [FeedingHistory] {
        var history: [FeedingHistory] = []
        let now = Temporal.DateTime.now()

        for i in 0..<count {
            let status: FeedingStatus = [.approved, .pending, .rejected].randomElement() ?? .pending
            let daysAgo = (i + 1) * 2

            let createdAt = now.add(value: -daysAgo, to: .day) ?? now

            let feedingHistory = FeedingHistory(
                id: "mock-fh-\(UUID().uuidString)",
                userId: "mock-user-\(Int.random(in: 1...5))",
                images: generateImageKeys(count: Int.random(in: 1...4)),
                createdAt: createdAt,
                updatedAt: createdAt,
                createdBy: "mock-user",
                updatedBy: "mock-user",
                owner: "mock-owner",
                feedingPointId: feedingPointId,
                feedingPointDetails: nil,
                status: status,
                reason: status == .rejected ? "Photo does not meet requirements" : nil,
                moderatedBy: status != .pending ? "mock-moderator" : nil,
                moderatedAt: status != .pending ? createdAt.add(value: 1, to: .hour) : nil,
                assignedModerators: nil
            )

            history.append(feedingHistory)
        }

        return history
    }

    static func generateMockFeeding(for feedingPointId: String) -> Feeding? {
        guard Bool.random() else { return nil }

        let now = Date()
        let expireAt = Int(now.addingTimeInterval(3600).timeIntervalSince1970)

        return Feeding(
            id: "mock-feeding-\(UUID().uuidString)",
            userId: "mock-user-\(Int.random(in: 1...5))",
            images: [],
            status: .inProgress,
            createdAt: Temporal.DateTime.now(),
            updatedAt: Temporal.DateTime.now(),
            feedingPointFeedingsId: feedingPointId,
            expireAt: expireAt
        )
    }

    private static func generateImageKeys(count: Int) -> [String] {
        (0..<count).map { _ in "mock-image-\(UUID().uuidString).jpg" }
    }

    private static func generateCoverImageKey() -> String {
        "mock-cover-\(UUID().uuidString).jpg"
    }
}

extension Temporal.DateTime {
    func add(value: Int, to component: Calendar.Component) -> Temporal.DateTime? {
        guard let newDate = Calendar.current.date(byAdding: component, value: value, to: foundationDate) else {
            return nil
        }
        return Temporal.DateTime(newDate)
    }
}
