// System
import Foundation

// SDK
import Services

enum FeatureFlags {
    private enum Keys: String, LocalStorageKeysProtocol {
        case loadAllFeedingPoints
    }

    private static let loadAllFeedingPointsDefault = true

    @UserDefaultFlag(key: Keys.loadAllFeedingPoints)
    private static var loadAllFeedingPointsOverride: Bool?

    static var isLoadAllFeedingPointsEnabled: Bool {
        get {
            #if QA_MENU
            return loadAllFeedingPointsOverride ?? loadAllFeedingPointsDefault
            #else
            return loadAllFeedingPointsDefault
            #endif
        }
        set {
            #if QA_MENU
            loadAllFeedingPointsOverride = newValue
            #endif
        }
    }
}
