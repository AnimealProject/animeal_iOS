import Foundation

public typealias AuthenticationSignInHanler = (Result<AuthenticationSignInState, AuthenticationError>) -> Void
public typealias AuthenticationSignOutHanler = (Result<Void, AuthenticationError>) -> Void
public typealias DeleteUserHandler = AuthenticationSignOutHanler
public typealias AuthFetchSessionHandler = (Result<AuthenticationSession, AuthenticationError>) -> Void

public protocol AuthenticationServiceHolder {
    var authenticationService: AuthenticationServiceProtocol { get }
}

public protocol AuthenticationServiceProtocol: AnyObject {
    func signUp(username: AuthenticationInput, password: AuthenticationInput, options: [AuthenticationUserAttribute]?) async throws -> AuthenticationSignUpState

    func signIn(username: AuthenticationInput, password: AuthenticationInput?) async throws -> AuthenticationSignInState

    func signIn(username: AuthenticationInput) async throws -> AuthenticationSignInState

    func signIn(provider: AuthenticationProvider) async throws -> AuthenticationSignInState

    func signOut() async throws

    func confirmSignUp(for username: AuthenticationInput, otp: AuthenticationInput) async throws -> AuthenticationSignUpState

    func confirmSignIn(otp: AuthenticationInput) async throws -> AuthenticationSignInState

    func resendSignUpCode(for username: AuthenticationInput) async throws -> AuthenticationCodeDeliveryDetails

    func deleteUser() async throws

    func fetchAuthSession() async throws -> AuthenticationSession
}

public extension AuthenticationServiceProtocol {
    func signIn(provider: AuthenticationProvider, handler: @escaping AuthenticationSignInHanler) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.signIn(provider: provider)
                handler(.success(result))
            } catch let error as AuthenticationError {
                handler(.failure(error))
            } catch {
                handler(.failure(AuthenticationError.unknown("Something went wrong.")))
            }
        }
    }

    func signOut(handler: @escaping AuthenticationSignOutHanler) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.signOut()
                handler(.success(()))
            } catch let error as AuthenticationError {
                handler(.failure(error))
            } catch {
                handler(.failure(AuthenticationError.unknown("Something went wrong.")))
            }
        }
    }

    func deleteUser(handler: @escaping DeleteUserHandler) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.deleteUser()
                handler(.success(()))
            } catch let error as AuthenticationError {
                handler(.failure(error))
            } catch {
                handler(.failure(AuthenticationError.unknown("Something went wrong.")))
            }
        }
    }

    func fetchAuthSession(handler: @escaping AuthFetchSessionHandler) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.fetchAuthSession()
                handler(.success(result))
            } catch let error as AuthenticationError {
                handler(.failure(error))
            } catch {
                handler(.failure(AuthenticationError.unknown("Something went wrong.")))
            }
        }
    }
}
