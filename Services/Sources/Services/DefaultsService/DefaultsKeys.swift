import Foundation

public protocol LocalStorageKeysProtocol {
    var rawValue: String { get }
}

public enum DefaultsKeys: String, LocalStorageKeysProtocol {
    case login
    case user
    case lastAppLaunch
}
