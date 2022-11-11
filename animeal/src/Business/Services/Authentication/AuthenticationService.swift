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
        options: [AuthenticationUserAttribute]?,
        handler: @escaping AuthenticationSignUpHandler
    ) {
        var signUpOptions: AuthSignUpRequest.Options?
        if let options = options {
            let userAttributes = options.map(converter.convertAuthenticationAttribute)
            signUpOptions = AuthSignUpRequest.Options(userAttributes: userAttributes)
        }

        Amplify.Auth.signUp(
            username: username.value,
            password: password.value,
            options: signUpOptions
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                guard let nextStep = self.converter.convertAmplifySignUpState(state) else {
                    handler(.failure(AuthenticationError.unknown("Confirmation code sent to unknown destenation", nil)))
                    return
                }
                handler(.success(nextStep))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func signIn(
        username: AuthenticationInput,
        password: AuthenticationInput?,
        handler: @escaping AuthenticationSignInHanler
    ) {
        guard let password = password else {
            return signIn(username: username, handler: handler)
        }

        Amplify.Auth.signIn(username: username.value, password: password.value) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(self.converter.convertAmplifySignInState(state)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func signIn(
        username: AuthenticationInput,
        handler: @escaping AuthenticationSignInHanler
    ) {
        let options = AuthSignInRequest.Options(
            pluginOptions: AWSAuthSignInOptions(authFlowType: .custom)
        )
        Amplify.Auth.signIn(username: username.value, options: options) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(self.converter.convertAmplifySignInState(state)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func signIn(
        provider: AuthenticationProvider,
        handler: @escaping AuthenticationSignInHanler
    ) {
        switch provider {
        case .apple(let presentationAnchor):
            Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: presentationAnchor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let state):
                    handler(.success(self.converter.convertAmplifySignInState(state)))
                case .failure(let error):
                    handler(.failure(self.converter.convertAmplifyError(error)))
                }
            }
        case .facebook(let presentationAnchor):
            Amplify.Auth.signInWithWebUI(for: .facebook, presentationAnchor: presentationAnchor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let state):
                    handler(.success(self.converter.convertAmplifySignInState(state)))
                case .failure(let error):
                    handler(.failure(self.converter.convertAmplifyError(error)))
                }
            }
        default: return
        }
    }

    func signOut(handler: @escaping AuthenticationSignOutHanler) {
        Amplify.Auth.signOut { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func confirmSignUp(
        for username: AuthenticationInput,
        otp: AuthenticationInput,
        handler: @escaping AuthenticationConfirmSignUpHanler
    ) {
        Amplify.Auth.confirmSignUp(for: username.value, confirmationCode: otp.value) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                guard let nextStep = self.converter.convertAmplifySignUpState(state) else {
                    handler(.failure(AuthenticationError.unknown("Confirmation code sent to unknown destenation", nil)))
                    return
                }
                handler(.success(nextStep))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func confirmSignIn(otp: AuthenticationInput, handler: @escaping AuthenticationConfirmSignInHanler) {
        Amplify.Auth.confirmSignIn(challengeResponse: otp.value) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(self.converter.convertAmplifySignInState(state)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func resendSignUpCode(for username: AuthenticationInput, handler: @escaping AuthenticationResendCodeHandler) {
        Amplify.Auth.resendSignUpCode(for: username.value) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(self.converter.convertCodeDeliveryDetails(state)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func deleteUser(handler: @escaping DeleteUserHandler) {
        Amplify.Auth.deleteUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                handler(.success(()))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func fetchAuthSession(handler: @escaping AuthFetchSessionHandler) {
        Amplify.Auth.fetchAuthSession { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let session):
                handler(.success(AuthenticationSession(isSignedIn: session.isSignedIn)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }
}
