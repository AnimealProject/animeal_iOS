import Foundation
import Services
import UIKit

typealias LoginListener = (Result<AuthenticationSignInState, AuthenticationError>) -> Void

protocol LoginProviding: AnyObject {
    func authenticate(_ listener: @escaping LoginListener)
}

final class AppleLoginProvider: LoginProviding {
    private let presentationAnchor: UIWindow
    private let authenticationService: AuthenticationServiceProtocol

    init(presentationAnchor: UIWindow, authenticationService: AuthenticationServiceProtocol) {
        self.presentationAnchor = presentationAnchor
        self.authenticationService = authenticationService
    }

    func authenticate(_ listener: @escaping LoginListener) {
        authenticationService.signIn(
            provider: AuthenticationProvider.apple(presentationAnchor)
        ) { result in
            listener(result)
        }
    }
}

final class FacebookLoginProvider: LoginProviding {
    private let presentationAnchor: UIWindow
    private let authenticationService: AuthenticationServiceProtocol

    init(presentationAnchor: UIWindow, authenticationService: AuthenticationServiceProtocol) {
        self.presentationAnchor = presentationAnchor
        self.authenticationService = authenticationService
    }

    func authenticate(_ listener: @escaping LoginListener) {
        authenticationService.signIn(
            provider: AuthenticationProvider.facebook(presentationAnchor)
        ) { result in
            listener(result)
        }
    }
}
