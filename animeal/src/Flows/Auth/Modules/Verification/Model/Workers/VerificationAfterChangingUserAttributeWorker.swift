// System
import Foundation

// SDK
import Services

final class VerificationAfterChangingUserAttributeWorker: VerificationModelWorker {
    private let userProfileService: UserProfileServiceProtocol

    init(userProfileService: UserProfileServiceProtocol) {
        self.userProfileService = userProfileService
    }

    @discardableResult
    func confirmCode(
        _ code: VerificationModelCode,
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        try await userProfileService.confirm(
            userAttributeKey: attribute.key.userAttributeKey,
            confirmationCode: UserProfileInput(code.validate)
        )
        return .done
    }

    @discardableResult
    func resendCode(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        let result = try await userProfileService.resendConfirmationCode(
            forAttributeKey: attribute.key.userAttributeKey
        )
        return .confirmSignInWithSMSMFACode(
            VerificationModelCodeDeliveryDetails(
                destination: result.destination,
                attributeKey: result.attributeKey
            )
        )
    }

    @discardableResult
    func resendAttrUpdate(
        forAttribute attribute: VerificationModelAttribute
    ) async throws -> VerificationModelNextStep {
        let result = try await userProfileService.update(userAttribute:
                .init(attribute.key.userAttributeKey, value: attribute.value)
        )
        return .confirmSignInWithSMSMFACode(
            VerificationModelCodeDeliveryDetails(
                destination: .sms(nil),
                attributeKey: attribute.key.userAttributeKey
            )
        )
    }
}
