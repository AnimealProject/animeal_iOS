// System
import UIKit

// SDK
import Services
import Amplify
import AWSCognitoAuthPlugin

final class AuthenticationService: AuthenticationServiceProtocol {
    // MARK: - Private properties
    private let converter: AuthenticationAmplifyConverting & AmplifyAuthenticationConverting

    // MARK: - Initialization
    init(converter: AuthenticationAmplifyConverting & AmplifyAuthenticationConverting = AuthenticationAmplifyConverter()) {
        self.converter = converter
    }

    // MARK: - Main methods
    func signUp(
        username: AuthenticationInput,
        password: AuthenticationInput,
        options: [AuthenticationUserAttribute]?
    ) async throws -> AuthenticationSignUpState {
        var signUpOptions: AuthSignUpRequest.Options?
        if let options = options {
            let userAttributes = options.map(converter.convertAuthenticationAttribute)
            signUpOptions = AuthSignUpRequest.Options(userAttributes: userAttributes)
        }
        do {
            let result = try await Amplify.Auth.signUp(
                username: username.value,
                password: password.value,
                options: signUpOptions
            )

            guard let nextStep = converter.convertAmplifySignUpState(result) else {
                throw AuthenticationError.unknown("Confirmation code sent to unknown destenation", nil)
            }

            return nextStep
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func signIn(
        username: AuthenticationInput,
        password: AuthenticationInput?
    ) async throws -> AuthenticationSignInState {
        guard let password = password else {
            return try await signIn(username: username)
        }

        do {
            let result = try await Amplify.Auth.signIn(username: username.value, password: password.value)

            return converter.convertAmplifySignInState(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func signIn(username: AuthenticationInput) async throws -> AuthenticationSignInState {
        let options = AuthSignInRequest.Options(
            pluginOptions: AWSAuthSignInOptions(authFlowType: .customWithSRP)
        )
        do {
            let result = try await Amplify.Auth.signIn(username: username.value, options: options)
            return converter.convertAmplifySignInState(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func signIn(provider: AuthenticationProvider) async throws -> AuthenticationSignInState {
        switch provider {
        case .apple(let presentationAnchor):
            do {
                let result = try await Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: presentationAnchor)
                return converter.convertAmplifySignInState(result)
            } catch let error as AuthError {
                throw converter.convertAmplifyError(error)
            } catch {
                throw AuthenticationError.unknown(error.localizedDescription, error)
            }
        case .facebook(let presentationAnchor):
            do {
                let result = try await Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: presentationAnchor)
                return converter.convertAmplifySignInState(result)
            } catch let error as AuthError {
                throw converter.convertAmplifyError(error)
            } catch {
                throw AuthenticationError.unknown(error.localizedDescription, error)
            }
        default:
            throw AuthenticationError.unknown("Unknown social web ui provider.", nil)
        }
    }

    func signOut() async throws {
        _ = await Amplify.Auth.signOut()
    }

    func confirmSignUp(
        for username: AuthenticationInput,
        otp: AuthenticationInput
    ) async throws -> AuthenticationSignUpState {
        do {
            let result = try await Amplify.Auth.confirmSignUp(for: username.value, confirmationCode: otp.value)
            guard let nextStep = converter.convertAmplifySignUpState(result) else {
                throw AuthenticationError.unknown("Confirmation code sent to unknown destenation", nil)
            }
            return nextStep
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func confirmSignIn(otp: AuthenticationInput) async throws -> AuthenticationSignInState {
        do {
            let result = try await Amplify.Auth.confirmSignIn(challengeResponse: otp.value)
            return converter.convertAmplifySignInState(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func resendSignUpCode(for username: AuthenticationInput) async throws -> AuthenticationCodeDeliveryDetails {
        do {
            let result = try await Amplify.Auth.resendSignUpCode(for: username.value)
            return converter.convertCodeDeliveryDetails(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func deleteUser() async throws {
        do {
            _ = try await Amplify.Auth.deleteUser()
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }

    func fetchAuthSession() async throws -> AuthenticationSession {
        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            return AuthenticationSession(isSignedIn: result.isSignedIn)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
           throw AuthenticationError.unknown(error.localizedDescription, error)
        }
    }
}
