// System
import Foundation

// SDK
import Services
import Amplify

protocol AuthenticationAmplifyConverting {
    func convertAmplifyError(_ amplifyError: AuthError) -> AuthenticationError
    func convertAmplifyState(_ state: AuthSignInResult) -> AuthenticationSignInState
    func convertCodeDeliveryDetails(_ codeDeliveryDetails: AuthCodeDeliveryDetails) -> AuthenticationCodeDeliveryDetails
    func convertDeliveryDestination(_ deliveryDestination: DeliveryDestination) -> AuthenticationDeliveryDestination
    func converAuthUserAttributeKey(_ authUserAttributeKey: AuthUserAttributeKey?) -> AuthenticationUserAttributeKey?
}

struct AuthenticationAmplifyConverter: AuthenticationAmplifyConverting {
    func convertAmplifyError(_ amplifyError: AuthError) -> AuthenticationError {
        switch amplifyError {
        case let .configuration(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.configuration(errorDescription, recoverySuggestion, originalError)
        case let .service(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.service(errorDescription, recoverySuggestion, originalError)
        case let .unknown(errorDescription, originalError):
            return AuthenticationError.unknown(errorDescription, originalError)
        case let .validation(field, errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.validation(field, errorDescription, recoverySuggestion, originalError)
        case let .notAuthorized(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.notAuthorized(errorDescription, recoverySuggestion, originalError)
        case let .invalidState(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.invalidState(errorDescription, recoverySuggestion, originalError)
        case let .signedOut(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.signedOut(errorDescription, recoverySuggestion, originalError)
        case let .sessionExpired(errorDescription, recoverySuggestion, originalError):
            return AuthenticationError.sessionExpired(errorDescription, recoverySuggestion, originalError)
        }
    }

    func convertAmplifyState(_ state: AuthSignInResult) -> AuthenticationSignInState {
        switch state.nextStep {
        case let .confirmSignInWithSMSMFACode(codeDeliveryDetails, additionalInfo):
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.confirmSignInWithSMSCode(
                    convertCodeDeliveryDetails(codeDeliveryDetails),
                    additionalInfo
                )
            )
        case .confirmSignInWithCustomChallenge(let additionalInfo):
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.confirmSignInWithCustomChallenge(
                    additionalInfo
                )
            )
        case .confirmSignInWithNewPassword(let additionalInfo):
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.confirmSignInWithNewPassword(
                    additionalInfo
                )
            )
        case .resetPassword(let additionalInfo):
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.resetPassword(
                    additionalInfo
                )
            )
        case .confirmSignUp(let additionalInfo):
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.confirmSignUp(
                    additionalInfo
                )
            )
        case .done:
            return AuthenticationSignInState(
                nextStep: AuthenticationSignInStep.done
            )
        }
    }

    func convertCodeDeliveryDetails(_ codeDeliveryDetails: AuthCodeDeliveryDetails) -> AuthenticationCodeDeliveryDetails {
        return AuthenticationCodeDeliveryDetails(
            destination: convertDeliveryDestination(codeDeliveryDetails.destination),
            attributeKey: converAuthUserAttributeKey(codeDeliveryDetails.attributeKey)
        )
    }

    func convertDeliveryDestination(_ deliveryDestination: DeliveryDestination) -> AuthenticationDeliveryDestination {
        switch deliveryDestination {
        case .email(let destination):
            return AuthenticationDeliveryDestination.email(destination)
        case .phone(let destination):
            return AuthenticationDeliveryDestination.phone(destination)
        case .sms(let destination):
            return AuthenticationDeliveryDestination.sms(destination)
        case .unknown(let destination):
            return AuthenticationDeliveryDestination.unknown(destination)
        }
    }

    func converAuthUserAttributeKey(_ authUserAttributeKey: AuthUserAttributeKey?) -> AuthenticationUserAttributeKey? {
        guard let authUserAttributeKey = authUserAttributeKey else {
            return nil
        }

        switch authUserAttributeKey {
        case .address:
            return AuthenticationUserAttributeKey.address
        case .birthDate:
            return AuthenticationUserAttributeKey.birthDate
        case .email:
            return AuthenticationUserAttributeKey.email
        case .familyName:
            return AuthenticationUserAttributeKey.email
        case .gender:
            return AuthenticationUserAttributeKey.gender
        case .givenName:
            return AuthenticationUserAttributeKey.givenName
        case .locale:
            return AuthenticationUserAttributeKey.locale
        case .middleName:
            return AuthenticationUserAttributeKey.middleName
        case .name:
            return AuthenticationUserAttributeKey.name
        case .nickname:
            return AuthenticationUserAttributeKey.nickname
        case .phoneNumber:
            return AuthenticationUserAttributeKey.phoneNumber
        case .picture:
            return AuthenticationUserAttributeKey.picture
        case .preferredUsername:
            return AuthenticationUserAttributeKey.preferredUsername
        case .custom(let key):
            return AuthenticationUserAttributeKey.custom(key)
        case .unknown(let key):
            return AuthenticationUserAttributeKey.unknown(key)
        }
    }
}
