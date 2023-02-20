// System
import Foundation

// SDK
import Services
import Amplify

final class UserProfileService: UserProfileServiceProtocol {
    // MARK: - Private properties
    private let converter: UserProfileAmplifyConverting & AmplifyUserProfileConverting
    private let userValidationModel: UserProfileValidationModel

    // MARK: - Initialization
    init(
        converter: UserProfileAmplifyConverting & AmplifyUserProfileConverting = UserProfileAmplifyConverter(),
        userValidationModel: UserProfileValidationModel = UserValidationModel()
    ) {
        self.converter = converter
        self.userValidationModel = UserValidationModel()
    }

    // MARK: - Main methods
    func getCurrentUser() async -> UserCurrentProfile? {
        guard let user = try? await Amplify.Auth.getCurrentUser() else {
            return nil
        }
        return UserCurrentProfile(
            username: user.username,
            userId: user.userId
        )
    }

    func getCurrentUserValidationModel() -> UserProfileValidationModel {
        return userValidationModel
    }

    @discardableResult
    func fetchUserAttributes() async throws -> [UserProfileAttribute] {
        do {
            let result = try await Amplify.Auth.fetchUserAttributes()
            let attributes = result.compactMap(converter.convertAuthUserAttribute)
            userValidationModel.handleUserAttributesEvent(attributes)
            return attributes
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    func update(userAttribute: UserProfileAttribute) async throws -> UserProfileUpdateAttributeState {
        do {
            let result = try await Amplify.Auth.update(
                userAttribute: converter.convertUserProfileAttribute(userAttribute)
            )
            return converter.convertUpdateAttributeResult(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    func update(userAttributes: [UserProfileAttribute]) async throws -> UserProfileUpdateAttributesState {
        do {
            let result = try await Amplify.Auth.update(
                userAttributes: userAttributes.map(converter.convertUserProfileAttribute)
            )
            return converter.convertUpdateAttributesResult(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    func resendConfirmationCode(
        forAttributeKey attributeKey: UserProfileAttributeKey
    ) async throws -> UserProfileCodeDeliveryDetails {
        do {
            let result = try await Amplify.Auth.resendConfirmationCode(
                forUserAttributeKey: converter.convertUserProfileAttributeKey(attributeKey)
            )
            return converter.convertCodeDeliveryDetails(result)
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    func confirm(
        userAttributeKey: UserProfileAttributeKey,
        confirmationCode: UserProfileInput
    ) async throws {
        do {
            try await Amplify.Auth.confirm(
                userAttribute: converter.convertUserProfileAttributeKey(userAttributeKey),
                confirmationCode: confirmationCode.value
            )
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    func update(
        oldPassword: UserProfileInput,
        to newPassword: UserProfileInput
    ) async throws {
        do {
            try await Amplify.Auth.update(
                oldPassword: oldPassword.value,
                to: newPassword.value
            )
        } catch let error as AuthError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }
}
