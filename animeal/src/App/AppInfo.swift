import Foundation

enum AppInfo {
    static var appId: String {
        return "6478071465"
    }

    static var bundle: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? .empty
    }

    static var bundleName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? .empty
    }

    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? .empty
    }

    static var appBuildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? .empty
    }

    static var appStoreShareUrl: String {
        return "https://itunes.apple.com/us/app/iapps/id\(appId)?mt=8"
    }

    static var appStoreReviewUrl: String {
        return "https://apps.apple.com/us/app/animeal/id1641080306"
    }

    static var appStoreRateUrl: String {
        return "itms-apps://itunes.apple.com/app/\(appId)"
    }
}
