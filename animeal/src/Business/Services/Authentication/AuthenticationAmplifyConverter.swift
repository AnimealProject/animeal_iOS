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

protocol AmplifyAuthenticationConverting {
    func convertAuthenticationAttribute(_ attribute: AuthenticationUserAttribute) -> AuthUserAttribute
}

// swiftlint:disable cyclomatic_complexity
struct AuthenticationAmplifyConverter: AuthenticationAmplifyConverting, AmplifyAuthenticationConverting {
    func convertAuthenticationAttribute(_ attribute: AuthenticationUserAttribute) -> AuthUserAttribute {
        switch attribute.key {
        case .address:
            return AuthUserAttribute.init(AuthUserAttributeKey.address, value: attribute.value)
        case .birthDate:
            return AuthUserAttribute.init(AuthUserAttributeKey.birthDate, value: attribute.value)
        case .email:
            return AuthUserAttribute.init(AuthUserAttributeKey.email, value: attribute.value)
        case .familyName:
            return AuthUserAttribute.init(AuthUserAttributeKey.familyName, value: attribute.value)
        case .gender:
            return AuthUserAttribute.init(AuthUserAttributeKey.gender, value: attribute.value)
        case .givenName:
            return AuthUserAttribute.init(AuthUserAttributeKey.givenName, value: attribute.value)
        case .locale:
            return AuthUserAttribute.init(AuthUserAttributeKey.locale, value: attribute.value)
        case .middleName:
            return AuthUserAttribute.init(AuthUserAttributeKey.middleName, value: attribute.value)
        case .name:
            return AuthUserAttribute.init(AuthUserAttributeKey.name, value: attribute.value)
        case .nickname:
            return AuthUserAttribute.init(AuthUserAttributeKey.nickname, value: attribute.value)
        case .phoneNumber:
            return AuthUserAttribute.init(AuthUserAttributeKey.phoneNumber, value: attribute.value)
        case .picture:
            return AuthUserAttribute.init(AuthUserAttributeKey.picture, value: attribute.value)
        case .preferredUsername:
            return AuthUserAttribute.init(AuthUserAttributeKey.preferredUsername, value: attribute.value)
        case .custom(let key):
            return AuthUserAttribute.init(AuthUserAttributeKey.custom(key), value: attribute.value)
        case .unknown(let key):
            return AuthUserAttribute.init(AuthUserAttributeKey.unknown(key), value: attribute.value)
        case .emailVerified:
            return AuthUserAttribute.init(AuthUserAttributeKey.emailVerified, value: attribute.value)
        case .phoneNumberVerified:
            return AuthUserAttribute.init(AuthUserAttributeKey.phoneNumberVerified, value: attribute.value)
        case .profile:
            return AuthUserAttribute.init(AuthUserAttributeKey.profile, value: attribute.value)
        case .sub:
            return AuthUserAttribute.init(AuthUserAttributeKey.sub, value: attribute.value)
        case .updatedAt:
            return AuthUserAttribute.init(AuthUserAttributeKey.updatedAt, value: attribute.value)
        case .website:
            return AuthUserAttribute.init(AuthUserAttributeKey.website, value: attribute.value)
        case .zoneInfo:
            return AuthUserAttribute.init(AuthUserAttributeKey.zoneInfo, value: attribute.value)
        }
    }

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
        defer {
            logError(originalError)
        }
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
        case .smsRole:
            return AuthenticationDetailedError.smsRole
        case .emailRole:
            return AuthenticationDetailedError.emailRole
        case .externalServiceException:
            return AuthenticationDetailedError.externalServiceException
        case .limitExceededException:
            return AuthenticationDetailedError.limitExceededException
        case .resourceConflictException:
            return AuthenticationDetailedError.resourceConflictException
        }
    }

    func convertAmplifySignUpState(_ state: AuthSignUpResult) -> AuthenticationSignUpState? {
        switch state.nextStep {
        case .done:
            return AuthenticationSignUpState(
                AuthenticationSignUpStep.done
            )
        case let .confirmUser(codeDeliveryDetails, additionalInfo, _):
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
        case .done, .confirmSignInWithTOTPCode, .continueSignInWithTOTPSetup(_), .continueSignInWithMFASelection(_):
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
        case .emailVerified:
            return AuthenticationUserAttributeKey.emailVerified
        case .phoneNumberVerified:
            return AuthenticationUserAttributeKey.phoneNumberVerified
        case .profile:
            return AuthenticationUserAttributeKey.profile
        case .sub:
            return AuthenticationUserAttributeKey.sub
        case .updatedAt:
            return AuthenticationUserAttributeKey.updatedAt
        case .website:
            return AuthenticationUserAttributeKey.website
        case .zoneInfo:
            return AuthenticationUserAttributeKey.zoneInfo
        }
    }
}
// swiftlint:enable cyclomatic_complexity

extension AuthenticationAmplifyConverter {
    /// Log error to firebase crashlytics non fatal error
    /// - Parameter error: the error object
    func logError(_ error: Error) {
        let className = String(describing: Self.self)
        let baseError = BaseError(localizedDescription: error.localizedDescription)
        let errorEvent = ErrorEvent(screenClass: className, error: baseError)
        AppDelegate.shared.context.analyticsService.logEvent(errorEvent)
    }
}
