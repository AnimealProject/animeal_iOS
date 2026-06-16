// System
import Foundation

// SDK
import Services

@propertyWrapper
struct UserDefaultFlag<Value> {
    private let key: LocalStorageKeysProtocol
    private let defaultsService: DefaultsServiceProtocol

    init(
        key: LocalStorageKeysProtocol,
        defaultsService: DefaultsServiceProtocol = AppDelegate.shared.context.defaultsService
    ) {
        self.key = key
        self.defaultsService = defaultsService
    }

    var wrappedValue: Value? {
        get { defaultsService.value(key: key) }
        set { defaultsService.write(key: key, value: newValue) }
    }
}
