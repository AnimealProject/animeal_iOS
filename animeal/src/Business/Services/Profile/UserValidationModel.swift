import Foundation

// SDK
import Amplify
import Services

final class UserValidationModel: UserProfileValidationModel {
    // MARK: Properties
    private(set) var phoneNumberVerified: Bool = false
    private(set) var emailVerified: Bool = false
    private enum Constants {
        static let phoneNumberAttribute = "phone_number_verified"
    }

    // MARK: - Initialization
    init() {
        subscribeAuthChannelEvents()
    }

    // MARK: - UserProfileValidationModel
    var validated: Bool {
        return phoneNumberVerified && emailVerified
    }
}

// MARK: - Private API
private extension UserValidationModel {
    func subscribeAuthChannelEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] payload in
            guard let self = self else { return }
            switch payload.eventName {
            case HubPayload.EventName.Auth.userDeleted:
                self.emailVerified = false
                self.phoneNumberVerified = false
            case HubPayload.EventName.Auth.fetchUserAttributesAPI:
                self.handleUserAttributesEvent(data: payload.data)
            default:
                break
            }
        }
    }

    func handleUserAttributesEvent(data: Any?) {
        guard let result = data as? Result<[AuthUserAttribute], AuthError> else {
            return
        }
        switch result {
        case .success(let attributes):
            attributes.forEach { attribute in
                switch attribute.key {
                case .unknown(let value):
                    if value == Constants.phoneNumberAttribute {
                        phoneNumberVerified = Bool(attribute.value) ?? false
                    }
                case .email:
                    emailVerified = true
                default:
                    break
                }
            }
        default:
            break
        }
    }
}
