import Foundation

public protocol UserProfileServiceHolder {
    var profileService: UserProfileServiceProtocol { get }
}

public protocol UserProfileValidationModel {
    var isSignedIn: Bool { get }
    var validated: Bool { get }
    var phoneNumberVerified: Bool { get }
    var emailVerified: Bool { get }

    func handleUserAttributesEvent(_ attributes: [UserProfileAttribute])
}

public protocol UserProfileServiceProtocol: AnyObject {
    /// Returns the currently logged in user.
    ///
    func getCurrentUser() async -> UserCurrentProfile?

    /// Returns the currently logged in user validation model
    ///
    func getCurrentUserValidationModel() -> UserProfileValidationModel

    /// Fetch user attributes for the current user.
    ///
    @discardableResult
    func fetchUserAttributes() async throws -> [UserProfileAttribute]

    /// Update user attribute for the current user
    ///
    /// - Parameters:
    ///   - userAttribute: Attribute that need to be updated
    func update(userAttribute: UserProfileAttribute) async throws -> UserProfileUpdateAttributeState

    /// Update a list of user attributes for the current user
    ///
    /// - Parameters:
    ///   - userAttributes: List of attribtues that need ot be updated
    func update(userAttributes: [UserProfileAttribute]) async throws -> UserProfileUpdateAttributesState

    /// Resends the confirmation code required to verify an attribute
    ///
    /// - Parameters:
    ///   - attributeKey: Attribute to be verified
    func resendConfirmationCode(forAttributeKey attributeKey: UserProfileAttributeKey) async throws -> UserProfileCodeDeliveryDetails

    /// Confirm an attribute using confirmation code
    ///
    /// - Parameters:
    ///   - userAttribute: Attribute to verify
    ///   - confirmationCode: Confirmation code received
    func confirm(userAttributeKey: UserProfileAttributeKey, confirmationCode: UserProfileInput) async throws

    /// Update the current logged in user's password
    ///
    /// Check the plugins documentation, you might need to re-authenticate the user after calling this method.
    /// - Parameters:
    ///   - oldPassword: Current password of the user
    ///   - newPassword: New password to be updated
    func update(oldPassword: UserProfileInput, to newPassword: UserProfileInput) async throws

    /// Fetches names for specified user list
    ///
    /// - Parameters:
    ///  - userIds: List of user identifiers
    func fetchUserNames(for userIds: [String]) async throws -> [String: String]
}

public extension UserProfileServiceProtocol {
    func fetchUserAttributes(handler: @escaping (Result<[UserProfileAttribute], UserProfileError>) -> Void) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.fetchUserAttributes()
                handler(.success(result))
            } catch let error as UserProfileError {
                handler(.failure(error))
            } catch {
                handler(.failure(.unknown("Something went wrong.")))
            }
        }
    }
}
