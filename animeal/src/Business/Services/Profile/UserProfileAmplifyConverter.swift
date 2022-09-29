// System
import Foundation

// SDK
import Services
import Amplify
import AWSCognitoAuthPlugin

protocol UserProfileAmplifyConverting {
    func convertAmplifyError(_ amplifyError: AuthError) -> UserProfileError
    func convertUpdateAttributeResult(_ updateUserAttributeResult: AuthUpdateAttributeResult) -> UserProfileUpdateAttributeState
    func convertUpdateAttributeStep(_ updateAttributeStep: AuthUpdateAttributeStep) -> UserProfileUpdateAttributeStep
    func convertUpdateAttributesResult(_ updateUserAttributeResult: [AuthUserAttributeKey: AuthUpdateAttributeResult]) -> UserProfileUpdateAttributesState
    func convertCodeDeliveryDetails(_ codeDeliveryDetails: AuthCodeDeliveryDetails) -> UserProfileCodeDeliveryDetails
    func convertDeliveryDestination(_ deliveryDestination: DeliveryDestination) -> UserProfileDeliveryDestination
    func convertAuthUserAttribute(_ authUserAttribute: AuthUserAttribute) -> UserProfileAttribute?
    func convertAuthUserAttributeKey(_ authUserAttributeKey: AuthUserAttributeKey?) -> UserProfileAttributeKey?
}

protocol AmplifyUserProfileConverting {
    func convertUserProfileAttribute(_ attribute: UserProfileAttribute) -> AuthUserAttribute
    func convertUserProfileAttributeKey(_ attributeKey: UserProfileAttributeKey) -> AuthUserAttributeKey
}

// swiftlint:disable cyclomatic_complexity
struct UserProfileAmplifyConverter: UserProfileAmplifyConverting, AmplifyUserProfileConverting {
    func convertUserProfileAttribute(_ attribute: UserProfileAttribute) -> AuthUserAttribute {
        return AuthUserAttribute.init(convertUserProfileAttributeKey(attribute.key), value: attribute.value)
    }
    
    func convertUserProfileAttributeKey(_ attributeKey: UserProfileAttributeKey) -> AuthUserAttributeKey {
        switch attributeKey {
        case .address:
            return AuthUserAttributeKey.address
        case .birthDate:
            return AuthUserAttributeKey.birthDate
        case .email:
            return AuthUserAttributeKey.email
        case .familyName:
            return AuthUserAttributeKey.familyName
        case .gender:
            return AuthUserAttributeKey.gender
        case .givenName:
            return AuthUserAttributeKey.givenName
        case .locale:
            return AuthUserAttributeKey.locale
        case .middleName:
            return AuthUserAttributeKey.middleName
        case .name:
            return AuthUserAttributeKey.name
        case .nickname:
            return AuthUserAttributeKey.nickname
        case .phoneNumber:
            return AuthUserAttributeKey.phoneNumber
        case .picture:
            return AuthUserAttributeKey.picture
        case .preferredUsername:
            return AuthUserAttributeKey.preferredUsername
        case .custom(let key):
            return AuthUserAttributeKey.custom(key)
        case .unknown(let key):
            return AuthUserAttributeKey.unknown(key)
        }
    }

    func convertAmplifyError(_ amplifyError: AuthError) -> UserProfileError {
        switch amplifyError {
        case let .configuration(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.configuration(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .service(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.service(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .unknown(errorDescription, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.unknown(errorDescription, convertedOriginalError)
        case let .validation(field, errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.validation(field, errorDescription, recoverySuggestion, convertedOriginalError)
        case let .notAuthorized(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.notAuthorized(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .invalidState(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.invalidState(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .signedOut(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.signedOut(errorDescription, recoverySuggestion, convertedOriginalError)
        case let .sessionExpired(errorDescription, recoverySuggestion, originalError):
            let convertedOriginalError = convertOriginalError(originalError)
            return UserProfileError.sessionExpired(errorDescription, recoverySuggestion, convertedOriginalError)
        }
    }

    func convertOriginalError(_ originalError: Error?) -> UserProfileDetailedError? {
        guard let originalError = originalError as? AWSCognitoAuthError else { return nil }
        switch originalError {
        case .userNotFound:
            return UserProfileDetailedError.userNotFound
        case .userNotConfirmed:
            return UserProfileDetailedError.userNotConfirmed
        case .usernameExists:
            return UserProfileDetailedError.usernameExists
        case .aliasExists:
            return UserProfileDetailedError.aliasExists
        case .codeDelivery:
            return UserProfileDetailedError.codeDelivery
        case .codeMismatch:
            return UserProfileDetailedError.codeMismatch
        case .codeExpired:
            return UserProfileDetailedError.codeExpired
        case .invalidParameter:
            return UserProfileDetailedError.invalidParameter
        case .invalidPassword:
            return UserProfileDetailedError.invalidPassword
        case .limitExceeded:
            return UserProfileDetailedError.limitExceeded
        case .mfaMethodNotFound:
            return UserProfileDetailedError.mfaMethodNotFound
        case .softwareTokenMFANotEnabled:
            return UserProfileDetailedError.softwareTokenMFANotEnabled
        case .passwordResetRequired:
            return UserProfileDetailedError.passwordResetRequired
        case .resourceNotFound:
            return UserProfileDetailedError.resourceNotFound
        case .failedAttemptsLimitExceeded:
            return UserProfileDetailedError.failedAttemptsLimitExceeded
        case .requestLimitExceeded:
            return UserProfileDetailedError.requestLimitExceeded
        case .lambda:
            return nil
        case .deviceNotTracked:
            return UserProfileDetailedError.deviceNotTracked
        case .errorLoadingUI:
            return UserProfileDetailedError.errorLoadingUI
        case .userCancelled:
            return UserProfileDetailedError.userCancelled
        case .invalidAccountTypeException:
            return UserProfileDetailedError.invalidAccountTypeException
        case .network:
            return UserProfileDetailedError.network
        }
    }

    func convertUpdateAttributeResult(_ updateUserAttributeResult: AuthUpdateAttributeResult) -> UserProfileUpdateAttributeState {
        return UserProfileUpdateAttributeState(
            isUpdated: updateUserAttributeResult.isUpdated,
            nextStep: convertUpdateAttributeStep(updateUserAttributeResult.nextStep)
        )
    }

    func convertUpdateAttributeStep(_ updateAttributeStep: AuthUpdateAttributeStep) -> UserProfileUpdateAttributeStep {
        switch updateAttributeStep {
        case let .confirmAttributeWithCode(details, additionalInfo):
            return UserProfileUpdateAttributeStep.confirmAttributeWithCode(
                convertCodeDeliveryDetails(details), additionalInfo
            )
        case .done:
            return UserProfileUpdateAttributeStep.done
        }
    }

    func convertUpdateAttributesResult(
        _ updateUserAttributeResult: [AuthUserAttributeKey: AuthUpdateAttributeResult]
    ) -> UserProfileUpdateAttributesState {
        let converted = updateUserAttributeResult
            .compactMap { key, value -> (UserProfileAttributeKey, UserProfileUpdateAttributeState)? in
                guard let key = convertAuthUserAttributeKey(key) else { return nil }
                return (key, convertUpdateAttributeResult(value))
            }
        return Dictionary(uniqueKeysWithValues: converted)
    }

    func convertCodeDeliveryDetails(_ codeDeliveryDetails: AuthCodeDeliveryDetails) -> UserProfileCodeDeliveryDetails {
        return UserProfileCodeDeliveryDetails(
            destination: convertDeliveryDestination(codeDeliveryDetails.destination),
            attributeKey: convertAuthUserAttributeKey(codeDeliveryDetails.attributeKey)
        )
    }

    func convertDeliveryDestination(_ deliveryDestination: DeliveryDestination) -> UserProfileDeliveryDestination {
        switch deliveryDestination {
        case .email(let destination):
            return UserProfileDeliveryDestination.email(destination)
        case .phone(let destination):
            return UserProfileDeliveryDestination.phone(destination)
        case .sms(let destination):
            return UserProfileDeliveryDestination.sms(destination)
        case .unknown(let destination):
            return UserProfileDeliveryDestination.unknown(destination)
        }
    }

    func convertAuthUserAttribute(_ authUserAttribute: AuthUserAttribute) -> UserProfileAttribute? {
        guard
            let convertedKey = convertAuthUserAttributeKey(authUserAttribute.key)
        else { return nil }
        return UserProfileAttribute(convertedKey, value: authUserAttribute.value)
    }

    func convertAuthUserAttributeKey(_ authUserAttributeKey: AuthUserAttributeKey?) -> UserProfileAttributeKey? {
        guard let authUserAttributeKey = authUserAttributeKey else {
            return nil
        }

        switch authUserAttributeKey {
        case .address:
            return UserProfileAttributeKey.address
        case .birthDate:
            return UserProfileAttributeKey.birthDate
        case .email:
            return UserProfileAttributeKey.email
        case .familyName:
            return UserProfileAttributeKey.email
        case .gender:
            return UserProfileAttributeKey.gender
        case .givenName:
            return UserProfileAttributeKey.givenName
        case .locale:
            return UserProfileAttributeKey.locale
        case .middleName:
            return UserProfileAttributeKey.middleName
        case .name:
            return UserProfileAttributeKey.name
        case .nickname:
            return UserProfileAttributeKey.nickname
        case .phoneNumber:
            return UserProfileAttributeKey.phoneNumber
        case .picture:
            return UserProfileAttributeKey.picture
        case .preferredUsername:
            return UserProfileAttributeKey.preferredUsername
        case .custom(let key):
            return UserProfileAttributeKey.custom(key)
        case .unknown(let key):
            return UserProfileAttributeKey.unknown(key)
        }
    }
}
// swiftlint:enable cyclomatic_complexity
