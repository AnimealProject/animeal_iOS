// System
import Foundation

// SDK
import Services

enum FeatureFlags {
    private enum Keys: String, LocalStorageKeysProtocol {
        case loadAllFeedingPoints
    }

    /// Compile-time default, controlled via the `LOAD_ALL_FEEDING_POINTS`
    /// Active Compilation Condition (see `Configurations/Shared.xcconfig`).
    private static var loadAllFeedingPointsDefault: Bool {
        #if LOAD_ALL_FEEDING_POINTS
        return true
        #else
        return false
        #endif
    }

    @UserDefaultFlag(key: Keys.loadAllFeedingPoints)
    private static var loadAllFeedingPointsOverride: Bool?

    static var isLoadAllFeedingPointsEnabled: Bool {
        get {
            #if DEBUG
            return loadAllFeedingPointsOverride ?? loadAllFeedingPointsDefault
            #else
            return loadAllFeedingPointsDefault
            #endif
        }
        set {
            #if DEBUG
            loadAllFeedingPointsOverride = newValue
            #endif
        }
    }
}
