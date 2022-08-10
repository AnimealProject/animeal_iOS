import UIKit

public protocol DefaultsServiceHolder {
    var defaultsService: DefaultsServiceProtocol { get }
}

public protocol Storeable {
    var storeData: Data? { get }
    init?(storeData: Data?)
}

public protocol DefaultsServiceProtocol {
    // MARK: - Manage simple object
    func value<T>(key: LocalStorageKeysProtocol) -> T?
    func write<T>(key: LocalStorageKeysProtocol, value: T?)
    func remove(key: LocalStorageKeysProtocol)
    // MARK: - Manage complex object
    func valueStoreable<T>(key: LocalStorageKeysProtocol) -> T? where T: Storeable
    func writeStoreable<T>(key: LocalStorageKeysProtocol, value: T?) where T: Storeable
}

/// DefaultsService provides an interface to the user’s defaults database,
/// where you store key-value pairs persistently across launches of your app.
///
/// Usage example:
///
///     // For the simple object
///     storage.write(key: LocalStorageKeys.login, value: "Login")
///     let login1: String? = storage.value(key: LocalStorageKeys.login)
///
///     // For the complex object, adapt User struct conform to `LocalStorageKeysProtocol`
///     struct User: Codable, Storeable {
///     let name: String
///     let lastName: String
///
///     var storeData: Data? {
///         let encoder = JSONEncoder()
///         let encoded = try? encoder.encode(self)
///         return encoded
///     }
///
///     init?(storeData: Data?) {
///         guard let storeData = storeData else { return nil }
///         let decoder = JSONDecoder()
///         guard let decoded = try? decoder.decode(User.self, from: storeData) else { return nil }
///         self = decoded
///       }
///     }
///     let user: User = User(name: "Name", lastName: "LastName")
///     storage.writeStoreable(key: LocalStorageKeys.user, value: user)
///     let user1: User? = storage.valueStoreable(key: LocalStorageKeys.user)
///
///
public final class DefaultsService: DefaultsServiceProtocol {
    private lazy var store = UserDefaults.standard

    public init(store: UserDefaults = UserDefaults.standard) {
        self.store = store
    }

    public func value<T>(key: LocalStorageKeysProtocol) -> T? {
        return store.object(forKey: key.rawValue) as? T
    }

    public func write<T>(key: LocalStorageKeysProtocol, value: T?) {
        store.set(value, forKey: key.rawValue)
    }

    public func remove(key: LocalStorageKeysProtocol) {
        store.set(nil, forKey: key.rawValue)
    }

    public func valueStoreable<T>(key: LocalStorageKeysProtocol) -> T? where T: Storeable {
        let data: Data? = store.data(forKey: key.rawValue)
        return T(storeData: data)
    }

    public func writeStoreable<T>(key: LocalStorageKeysProtocol, value: T?) where T: Storeable {
        store.set(value?.storeData, forKey: key.rawValue)
    }
}

// MARK: - ApplicationService
extension DefaultsService: ApplicationDelegateService {
    public func registerApplication(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?
    ) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let currentDateTime = formatter.string(from: Date())
        write(key: DefaultsKeys.lastAppLaunch, value: currentDateTime)
        return true
    }
}
