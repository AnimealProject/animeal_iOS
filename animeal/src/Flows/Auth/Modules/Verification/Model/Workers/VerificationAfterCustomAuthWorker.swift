// System
import Foundation

// SDK
import Services

final class VerificationAfterCustomAuthWorker: VerificationModelWorker {
    private let authenticationService: AuthenticationServiceProtocol

    init(
        authenticationService: AuthenticationServiceProtocol = AppDelegate.shared.context.authenticationService
    ) {
        self.authenticationService = authenticationService
    }

    @discardableResult
    func confirmCode(
        _ code: VerificationModelCode,
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        let result = try await authenticationService.confirmSignIn(otp: UserProfileInput(code.validate))
        switch result.nextStep {
        case .confirmSignInWithSMSCode(let details, _):
            return .confirmSignInWithSMSMFACode(
                VerificationModelCodeDeliveryDetails(
                    destination: details.destination,
                    attributeKey: details.attributeKey
                )
            )
        case .confirmSignInWithCustomChallenge:
            return .confirmSignInWithCustomChallenge
        case .confirmSignInWithNewPassword:
            return .confirmSignInWithNewPassword
        case .resetPassword:
            return .resetPassword
        case .confirmSignUp:
            return .confirmSignUp
        case .done:
            return .done
        }
    }

    @discardableResult
    func resendCode(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        // need to check
//        try await authenticationService.signOut()
        let result = try await authenticationService.signIn(
            username: AuthenticationInput { attribute.value }
        )
        switch result.nextStep {
        case .confirmSignInWithSMSCode(let details, _):
            return .confirmSignInWithSMSMFACode(
                VerificationModelCodeDeliveryDetails(
                    destination: details.destination,
                    attributeKey: details.attributeKey
                )
            )
        case .confirmSignInWithCustomChallenge:
            return .confirmSignInWithCustomChallenge
        case .confirmSignInWithNewPassword:
            return .confirmSignInWithNewPassword
        case .resetPassword:
            return .resetPassword
        case .confirmSignUp:
            return .confirmSignUp
        case .done:
            return .done
        }
    }

    @discardableResult
    func resendAttrUpdate(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        try await resendCode(forAttribute: attribute)
    }
}
