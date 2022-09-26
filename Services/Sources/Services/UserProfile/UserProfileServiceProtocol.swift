import Foundation

public protocol UserProfileServiceProtocol {
    /// Returns the currently logged in user.
    ///
    func getCurrentUser() -> UserProfile?

    /// Fetch user attributes for the current user.
    ///
    /// - Parameters:
    ///   - handler: Triggered when the operation completes.
    func fetchUserAttributes(handler: @escaping (Result<[UserProfileAttribute], UserProfileError>) -> Void)

    /// Update user attribute for the current user
    ///
    /// - Parameters:
    ///   - userAttribute: Attribute that need to be updated
    ///   - handler: Triggered when the operation completes.
    func update(userAttribute: UserProfileAttribute, handler: @escaping (Result<UserProfileUpdateAttributeState, UserProfileError>) -> Void)

    /// Update a list of user attributes for the current user
    ///
    /// - Parameters:
    ///   - userAttributes: List of attribtues that need ot be updated
    ///   - handler: Triggered when the operation completes.
    func update(userAttributes: [UserProfileAttribute], handler: @escaping (Result<UserProfileUpdateAttributesState, UserProfileError>) -> Void)

    /// Resends the confirmation code required to verify an attribute
    ///
    /// - Parameters:
    ///   - attributeKey: Attribute to be verified
    ///   - handler: Triggered when the operation completes.
    func resendConfirmationCode(forAttributeKey attributeKey: UserProfileAttributeKey, handler: @escaping (Result<UserProfileCodeDeliveryDetails, UserProfileError>) -> Void)

    /// Confirm an attribute using confirmation code
    ///
    /// - Parameters:
    ///   - userAttribute: Attribute to verify
    ///   - confirmationCode: Confirmation code received
    ///   - handler: Triggered when the operation completes.
    func confirm(userAttributeKey: UserProfileAttributeKey, confirmationCode: UserProfileInput, handler: @escaping (Result<Void, UserProfileError>) -> Void)

    /// Update the current logged in user's password
    ///
    /// Check the plugins documentation, you might need to re-authenticate the user after calling this method.
    /// - Parameters:
    ///   - oldPassword: Current password of the user
    ///   - newPassword: New password to be updated
    ///   - handler: Triggered when the operation completes.
    func update(oldPassword: UserProfileInput, to newPassword: UserProfileInput, handler: @escaping (Result<Void, UserProfileError>) -> Void)
}

public extension UserProfileServiceProtocol {
    func fetchUserAttributes() async throws -> [UserProfileAttribute] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchUserAttributes { continuation.resume(with: $0) }
        }
    }

    func update(userAttribute: UserProfileAttribute) async throws -> UserProfileUpdateAttributeState {
        return try await withCheckedThrowingContinuation { continuation in
            update(userAttribute: userAttribute) { continuation.resume(with: $0) }
        }
    }

    func update(userAttributes: [UserProfileAttribute]) async throws -> UserProfileUpdateAttributesState {
        return try await withCheckedThrowingContinuation { continuation in
            update(userAttributes: userAttributes) { continuation.resume(with: $0) }
        }
    }

    func resendConfirmationCode(forAttributeKey attributeKey: UserProfileAttributeKey) async throws -> UserProfileCodeDeliveryDetails {
        return try await withCheckedThrowingContinuation { continuation in
            resendConfirmationCode(forAttributeKey: attributeKey) { continuation.resume(with: $0) }
        }
    }

    func confirm(userAttributeKey: UserProfileAttributeKey, confirmationCode: UserProfileInput) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            confirm(
                userAttributeKey: userAttributeKey,
                confirmationCode: confirmationCode
            ) { continuation.resume(with: $0) }
        }
    }

    func update(oldPassword: UserProfileInput, to newPassword: UserProfileInput) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            update(oldPassword: oldPassword, to: newPassword) { continuation.resume(with: $0) }
        }
    }
}
