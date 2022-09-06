import Foundation

public typealias AuthenticationSignUpHandler = (Result<AuthenticationSignUpState, AuthenticationError>) -> Void
public typealias AuthenticationSignInHanler = (Result<AuthenticationSignInState, AuthenticationError>) -> Void
public typealias AuthenticationSignOutHanler = (Result<Void, AuthenticationError>) -> Void
public typealias AuthenticationConfirmSignUpHanler = AuthenticationSignUpHandler
public typealias AuthenticationConfirmSignInHanler = AuthenticationSignInHanler

public protocol AuthenticationServiceHolder {
    var authenticationService: AuthenticationServiceProtocol { get }
}

public protocol AuthenticationServiceProtocol {
    var isSignedIn: Bool { get }

    func signUp(username: String, password: String, options: [AuthenticationUserAttribute]?, handler: @escaping AuthenticationSignUpHandler)

    func signIn(username: String, password: String, handler: @escaping AuthenticationSignInHanler)

    func signIn(username: String, handler: @escaping AuthenticationSignInHanler)

    func signIn(provider: AuthenticationProvider, handler: @escaping AuthenticationSignInHanler)

    func signOut(handler: @escaping AuthenticationSignOutHanler)

    func confirmSignUp(for username: String, otp: String, handler: @escaping AuthenticationConfirmSignUpHanler)

    func confirmSignIn(otp: String, handler: @escaping AuthenticationConfirmSignInHanler)
}

extension AuthenticationServiceProtocol {
    public func signUp(username: String, password: String, options: [AuthenticationUserAttribute]?) async throws -> AuthenticationSignUpState {
        try await withCheckedThrowingContinuation { continuation in
            signUp(username: username, password: password, options: options) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signIn(username: String, password: String) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            signIn(username: username, password: password) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signIn(username: String) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            signIn(username: username) {
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

    public func confirmSignUp(for username: String, otp: String) async throws -> AuthenticationSignUpState {
        try await withCheckedThrowingContinuation { continuation in
            confirmSignUp(for: username, otp: otp) {
                continuation.resume(with: $0)
            }
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
