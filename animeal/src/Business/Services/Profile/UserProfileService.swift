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
    func getCurrentUser() -> UserProfile? {
        guard let user = Amplify.Auth.getCurrentUser() else {
            return nil
        }
        return UserProfile(username: user.username, userId: user.userId)
    }

    func getCurrentUserValidationModel() -> UserProfileValidationModel {
        return userValidationModel
    }

    func fetchUserAttributes(
        handler: @escaping (Result<[UserProfileAttribute], UserProfileError>) -> Void
    ) {
        Amplify.Auth.fetchUserAttributes { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let attributes):
                handler(.success(attributes.compactMap(self.converter.convertAuthUserAttribute)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func update(
        userAttribute: UserProfileAttribute,
        handler: @escaping (Result<UserProfileUpdateAttributeState, UserProfileError>) -> Void
    ) {
        Amplify.Auth.update(
            userAttribute: converter.convertUserProfileAttribute(userAttribute)
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                handler(.success(self.converter.convertUpdateAttributeResult(result)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func update(
        userAttributes: [UserProfileAttribute],
        handler: @escaping (Result<UserProfileUpdateAttributesState, UserProfileError>) -> Void
    ) {
        Amplify.Auth.update(
            userAttributes: userAttributes.map(converter.convertUserProfileAttribute)
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let result):
                handler(.success(self.converter.convertUpdateAttributesResult(result)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func resendConfirmationCode(
        forAttributeKey attributeKey: UserProfileAttributeKey,
        handler: @escaping (Result<UserProfileCodeDeliveryDetails, UserProfileError>) -> Void
    ) {
        Amplify.Auth.resendConfirmationCode(
            for: converter.convertUserProfileAttributeKey(attributeKey)
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let details):
                handler(.success(self.converter.convertCodeDeliveryDetails(details)))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func confirm(
        userAttributeKey: UserProfileAttributeKey,
        confirmationCode: UserProfileInput,
        handler: @escaping (Result<Void, UserProfileError>) -> Void
    ) {
        Amplify.Auth.confirm(
            userAttribute: converter.convertUserProfileAttributeKey(userAttributeKey),
            confirmationCode: confirmationCode.value
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(state))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }

    func update(
        oldPassword: UserProfileInput,
        to newPassword: UserProfileInput,
        handler: @escaping (Result<Void, UserProfileError>) -> Void
    ) {
        Amplify.Auth.update(
            oldPassword: oldPassword.value,
            to: newPassword.value
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let state):
                handler(.success(state))
            case .failure(let error):
                handler(.failure(self.converter.convertAmplifyError(error)))
            }
        }
    }
}
