import Foundation
import Services

protocol FeedingSnapshotStorable {
    var snaphot: FeedingSnapshot? { get }
    func save(_ id: String, date: Date)
    func removeStoredSnaphot()
}

final class FeedingSnapshotStore: FeedingSnapshotStorable {
    typealias Context = DefaultsServiceHolder
    private let context: Context

    enum Keys: String, LocalStorageKeysProtocol {
        case feedingSnapshot
    }

    init(context: Context = AppDelegate.shared.context) {
        self.context = context
    }

    var snaphot: FeedingSnapshot? {
        let snaphot: FeedingSnapshot? = context.defaultsService.valueStoreable(
            key: Keys.feedingSnapshot
        )
        return snaphot
    }

    func save(_ id: String, date: Date) {
        let snapshot = FeedingSnapshot(pointId: id, feedStartingDate: date)
        context.defaultsService.writeStoreable(key: Keys.feedingSnapshot, value: snapshot)
    }

    func removeStoredSnaphot() {
        context.defaultsService.remove(key: Keys.feedingSnapshot)
    }
}

struct FeedingSnapshot: Codable, Storeable {
    let pointId: String
    let feedStartingDate: Date
    let startingTimeDiff: TimeInterval

    init(pointId: String, feedStartingDate: Date) {
        self.pointId = pointId
        self.feedStartingDate = feedStartingDate
        self.startingTimeDiff = NetTime.serverTimeDifference
    }

    var storeData: Data? {
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return encoded
    }

    init?(storeData: Data?) {
        guard let storeData = storeData else { return nil }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(FeedingSnapshot.self, from: storeData) else {
            return nil
        }
        self = decoded
    }
}
