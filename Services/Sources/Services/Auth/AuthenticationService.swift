import Foundation

public typealias AuthenticationSignInHanler = (Result<AuthenticationSignInState, AuthenticationError>) -> Void
public typealias AuthenticationSignOutHanler = (Result<Void, AuthenticationError>) -> Void
public typealias AuthenticationConfirmSignInHanler = AuthenticationSignInHanler

public protocol AuthenticationServiceHolder {
    var authenticationService: AuthenticationServiceProtocol { get }
}

public protocol AuthenticationServiceProtocol {
    func signIn(username: String, password: String, handler: @escaping AuthenticationSignInHanler)

    func signIn(provider: AuthenticationProvider, handler: @escaping AuthenticationSignInHanler)

    func signOut(handler: @escaping AuthenticationSignOutHanler)

    func confirmSignIn(otp: String, handler: @escaping AuthenticationConfirmSignInHanler)
}

extension AuthenticationServiceProtocol {
    public func signIn(username: String, password: String) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            signIn(username: username, password: password) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signIn(provider: AuthenticationProvider) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            signIn(provider: provider) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signOut() async throws {
        try await withCheckedThrowingContinuation { continuation in
            signOut { continuation.resume(with: $0) }
        }
    }

    public func confirmSignIn(otp: String) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            confirmSignIn(otp: otp) {
                continuation.resume(with: $0)
            }
        }
    }
}
