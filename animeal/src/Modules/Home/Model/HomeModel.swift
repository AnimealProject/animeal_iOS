import Foundation


final class HomeModel: HomeModelProtocol {
    // MARK: - Initialization
    init() { }

    // MARK: - Requests
    func fetchFeedingPoints(_ completion: (([FeedingPoint]) -> Void)?) {
        // Fake data used here
        let points = [
            // Akaki Tsereteli Avenue 7, 0119 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.73252135744818, longitude: 44.784740558407265),
                pet: .dog,
                hungerLevel: .low
            ),
            // Spiridon Kedia Street, 0119 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.73234080910943, longitude: 44.78767936105234),
                pet: .dog,
                hungerLevel: .high
            ),
            // Megaline, Razhden Gvetadze St, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.72941679186787, longitude: 44.78358255002624),
                pet: .dog,
                hungerLevel: .mid
            ),
            // Akaki Tsereteli Avenue 2, 0154 Tbilisi, Georgia
            FeedingPoint(
                identifier: UUID().uuidString,
                location: Location(latitude: 41.731819746852416, longitude: 44.784159255086905),
                pet: .dog,
                hungerLevel: .low
            )
        ]
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion?(points)
        }
    }
}
