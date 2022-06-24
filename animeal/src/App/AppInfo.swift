import Foundation

enum AppInfo {
    static var appId: String {
        return "" // TODO: Add appId
    }

    static var bundle: String {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    }

    static var bundleName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
    }

    static var appStoreShareUrl: String {
        return "https://itunes.apple.com/us/app/iapps/id\(appId)?mt=8"
    }

    static var appStoreReviewUrl: String {
        return "" // TODO: Add appAppStoreReviewUrl
    }

    static var appStoreRateUrl: String {
        return "itms-apps://itunes.apple.com/app/\(appId)"
    }
}
