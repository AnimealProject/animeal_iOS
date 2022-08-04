// System
import UIKit

// SDK
import Services
import Amplify
import AWSCognitoAuthPlugin

final class AuthenticationService: AuthenticationServiceProtocol {
    private let converter: AuthenticationAmplifyConverting

    init(converter: AuthenticationAmplifyConverting = AuthenticationAmplifyConverter()) {
        self.converter = converter
    }

    func signUp(
        username: String,
        password: String,
        options: [AuthenticationUserAttribute]?,
        handler: @escaping AuthenticationSignUpHandler
    ) {
        Amplify.Auth.signUp(username: username, password: password) { [weak self] result in
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
        username: String,
        password: String,
        options: [AuthenticationUserAttribute]?,
        handler: @escaping AuthenticationSignInHanler
    ) {
        Amplify.Auth.signIn(username: username, password: password) { [weak self] result in
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
        options: [AuthenticationUserAttribute]?,
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
            Amplify.Auth.signInWithWebUI(for: .apple, presentationAnchor: presentationAnchor) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let state):
                    handler(.success(self.converter.convertAmplifySignInState(state)))
                case .failure(let error):
                    handler(.failure(self.converter.convertAmplifyError(error)))
                }
            }
        case .custom(let userAttributes):
            guard
                let username = userAttributes[.username],
                let password = userAttributes[.password]
            else {
                handler(.failure(
                    AuthenticationError.unknown("Username or password field is nil", nil)
                ))
                return
            }
            self.signIn(username: username, password: password, options: nil, handler: handler)
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

    func confirmSignUp(for username: String, otp: String, handler: @escaping AuthenticationConfirmSignUpHanler) {
        Amplify.Auth.confirmSignUp(for: username, confirmationCode: otp) { [weak self] result in
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

    func confirmSignIn(otp: String, handler: @escaping AuthenticationConfirmSignInHanler) {
        Amplify.Auth.confirmSignIn(challengeResponse: otp) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(self.converter.convertAmplifySignInState(state)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }
}

extension AuthenticationService: ApplicationDelegateService {
    func registerApplication(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [AnyHashable: Any]?
    ) -> Bool {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            logInfo("Amplify configured with auth plugin")
        } catch {
            logInfo("Failed to initialize Amplify with \(error)")
        }

        return true
    }
}
