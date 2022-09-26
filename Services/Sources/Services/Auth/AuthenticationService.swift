import Foundation

public typealias AuthenticationSignUpHandler = (Result<AuthenticationSignUpState, AuthenticationError>) -> Void
public typealias AuthenticationSignInHanler = (Result<AuthenticationSignInState, AuthenticationError>) -> Void
public typealias AuthenticationSignOutHanler = (Result<Void, AuthenticationError>) -> Void
public typealias AuthenticationConfirmSignUpHanler = AuthenticationSignUpHandler
public typealias AuthenticationConfirmSignInHanler = AuthenticationSignInHanler
public typealias AuthenticationResendCodeHandler = (Result<AuthenticationCodeDeliveryDetails, AuthenticationError>) -> Void
public typealias DeleteUserHandler = AuthenticationSignOutHanler

public protocol AuthenticationServiceHolder {
    var authenticationService: AuthenticationServiceProtocol { get }
}

public protocol AuthenticationServiceProtocol {
    var isSignedIn: Bool { get }

    func signUp(username: AuthenticationInput, password: AuthenticationInput, options: [AuthenticationUserAttribute]?, handler: @escaping AuthenticationSignUpHandler)

    func signIn(username: AuthenticationInput, password: AuthenticationInput?, handler: @escaping AuthenticationSignInHanler)

    func signIn(username: AuthenticationInput, handler: @escaping AuthenticationSignInHanler)

    func signIn(provider: AuthenticationProvider, handler: @escaping AuthenticationSignInHanler)

    func signOut(handler: @escaping AuthenticationSignOutHanler)

    func confirmSignUp(for username: AuthenticationInput, otp: AuthenticationInput, handler: @escaping AuthenticationConfirmSignUpHanler)

    func confirmSignIn(otp: AuthenticationInput, handler: @escaping AuthenticationConfirmSignInHanler)

    func resendSignUpCode(for username: AuthenticationInput, handler: @escaping AuthenticationResendCodeHandler)

    func deleteUser(handler: @escaping DeleteUserHandler)
}

extension AuthenticationServiceProtocol {
    public func signUp(username: AuthenticationInput, password: AuthenticationInput, options: [AuthenticationUserAttribute]?) async throws -> AuthenticationSignUpState {
        try await withCheckedThrowingContinuation { continuation in
            signUp(username: username, password: password, options: options) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signIn(username: AuthenticationInput, password: AuthenticationInput?) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            signIn(username: username, password: password) {
                continuation.resume(with: $0)
            }
        }
    }

    public func signIn(username: AuthenticationInput) async throws -> AuthenticationSignInState {
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

    public func confirmSignUp(for username: AuthenticationInput, otp: AuthenticationInput) async throws -> AuthenticationSignUpState {
        try await withCheckedThrowingContinuation { continuation in
            confirmSignUp(for: username, otp: otp) {
                continuation.resume(with: $0)
            }
        }
    }

    public func confirmSignIn(otp: AuthenticationInput) async throws -> AuthenticationSignInState {
        try await withCheckedThrowingContinuation { continuation in
            confirmSignIn(otp: otp) {
                continuation.resume(with: $0)
            }
        }
    }

    public func resendSignUpCode(for username: AuthenticationInput) async throws -> AuthenticationCodeDeliveryDetails {
        try await withCheckedThrowingContinuation { continuation in
            resendSignUpCode(for: username) {
                continuation.resume(with: $0)
            }
        }
    }

    public func deleteUser() async throws {
        try await withCheckedThrowingContinuation { continuation in
            deleteUser {
                continuation.resume(with: $0)
            }
        }
    }
}
