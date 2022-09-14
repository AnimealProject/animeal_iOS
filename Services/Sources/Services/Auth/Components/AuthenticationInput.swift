import Foundation

public protocol AuthenticationInputValidatable {
    init(_ validator: @escaping () throws -> String) throws
}

public struct AuthenticationInput: AuthenticationInputValidatable {
    public let value: String

    public init(_ validator: @escaping () throws -> String) throws {
        let value = try validator()
        self.value = value
    }
}
