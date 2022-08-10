// System
import Foundation

// SDK
import Services
import Amplify
import AWSCognitoAuthPlugin

protocol AuthenticationAmplifyConverting {
    func convertAmplifyError(_ amplifyError: AuthError) -> AuthenticationError
    func convertAmplifySignUpState(_ state: AuthSignUpResult) -> AuthenticationSignUpState?
    func convertAmplifySignInState(_ state: AuthSignInResult) -> AuthenticationSignInState
    func convertCodeDeliveryDetails(_ codeDeliveryDetails: AuthCodeDeliveryDetails) -> AuthenticationCodeDeliveryDetails
    func convertDeliveryDestination(_ deliveryDestination: DeliveryDestination) -> AuthenticationDeliveryDestination
    func converAuthUserAttributeKey(_ authUserAttributeKey: AuthUserAttributeKey?) -> AuthenticationUserAttributeKey?
}

// swiftlint:disable cyclomatic_complexity
struct AuthenticationAmplifyConverter: AuthenticationAmplifyConverting {
    func convertAmplifyError(_ amplifyError: AuthError) -> AuthenticationError {
        switch amplifyError {
        case let .configuration(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.configuration(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .service(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.service(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .unknown(errorDescription, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.unknown(errorDescription, convertedOriginalError)
        case let .validation(field, errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.validation(field, errorDescription, recoverySuggestion, convertedOriginalError)
        case let .notAuthorized(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.notAuthorized(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .invalidState(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.invalidState(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .signedOut(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.signedOut(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .sessionExpired(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return AuthenticationError.sessionExpired(errorDescription, recoverySuggestion, convertedOriginalError)
        }
    }
    
    func convertOriginalError(_ originalError: Error?) -> AuthenticationDetailedError? {
        guard let originalError = originalError as? AWSCognitoAuthError else { return nil }
        switch originalError {
        case .userNotFound:
            return AuthenticationDetailedError.userNotFound
        case .userNotConfirmed:
            return AuthenticationDetailedError.userNotConfirmed
        case .usernameExists:
            return AuthenticationDetailedError.usernameExists
        case .aliasExists:
            return AuthenticationDetailedError.aliasExists
        case .codeDelivery:
            return AuthenticationDetailedError.codeDelivery
        case .codeMismatch:
            return AuthenticationDetailedError.codeMismatch
        case .codeExpired:
            return AuthenticationDetailedError.codeExpired
        case .invalidParameter:
            return AuthenticationDetailedError.invalidParameter
        case .invalidPassword:
            return AuthenticationDetailedError.invalidPassword
        case .limitExceeded:
            return AuthenticationDetailedError.limitExceeded
        case .mfaMethodNotFound:
            return AuthenticationDetailedError.mfaMethodNotFound
        case .softwareTokenMFANotEnabled:
            return AuthenticationDetailedError.softwareTokenMFANotEnabled
        case .passwordResetRequired:
            return AuthenticationDetailedError.passwordResetRequired
        case .resourceNotFound:
            return AuthenticationDetailedError.resourceNotFound
        case .failedAttemptsLimitExceeded:
            return AuthenticationDetailedError.failedAttemptsLimitExceeded
        case .requestLimitExceeded:
            return AuthenticationDetailedError.requestLimitExceeded
        case .lambda:
            return nil
        case .deviceNotTracked:
            return AuthenticationDetailedError.deviceNotTracked
        case .errorLoadingUI:
            return AuthenticationDetailedError.errorLoadingUI
        case .userCancelled:
            return AuthenticationDetailedError.userCancelled
        case .invalidAccountTypeException:
            return AuthenticationDetailedError.invalidAccountTypeException
        case .network:
            return AuthenticationDetailedError.network
        }
    }

    func convertAmplifySignUpState(_ state: AuthSignUpResult) -> AuthenticationSignUpState? {
        switch state.nextStep {
        case .done:
            return AuthenticationSignUpState(
                AuthenticationSignUpStep.done
            )
        case let .confirmUser(codeDeliveryDetails, additionalInfo):
            guard let codeDeliveryDetails = codeDeliveryDetails else { return nil }
            return AuthenticationSignUpState(
                AuthenticationSignUpStep.confirmUser(
                    convertCodeDeliveryDetails(codeDeliveryDetails),
                    additionalInfo
                )
            )
        }
    }

    func convertAmplifySignInState(_ state: AuthSignInResult) -> AuthenticationSignInState {
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
// swiftlint:enable cyclomatic_complexity
