import Foundation

// SDK
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Services

final class UserValidationModel: UserProfileValidationModel {
    // MARK: - Private Properties
    private var listeners: [AuthChannelEventsListener] = []
    private enum Constants {
        static let phoneNumberAttribute = "phone_number_verified"
    }

    // MARK: - Accessible properties
    private(set) var isSignedIn = false
    private(set) var phoneNumberVerified = false
    private(set) var emailVerified = false

    // MARK: - Initialization
    init() {
        listenAuthChannelMessages()
    }

    // MARK: - UserProfileValidationModel
    var validated: Bool {
        return phoneNumberVerified && emailVerified
    }
}

// MARK: - AuthChannelEventsPublisher
extension UserValidationModel: AuthChannelEventsPublisher {
    func subscribe(_ listener: AuthChannelEventsListener) {
        listeners.append(listener)
    }
}

// MARK: - Private API
private extension UserValidationModel {
    func listenAuthChannelMessages() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] payload in
            guard let self = self else { return }
            switch payload.eventName {
            case HubPayload.EventName.Auth.userDeleted:
                logInfo("[App] \(#function) Auth.userDeleted event occurred in AUTH channel")
                self.emailVerified = false
                self.phoneNumberVerified = false
                self.isSignedIn = false
            case HubPayload.EventName.Auth.fetchUserAttributesAPI:
                logInfo("[App] \(#function) Auth.fetchUserAttributesAPI event occurred in AUTH channel")
                self.handleUserAttributesEvent(data: payload.data)
            case HubPayload.EventName.Auth.sessionExpired:
                logInfo("[App] \(#function) Auth.sessionExpired event occurred in AUTH channel")
                self.isSignedIn = false
                self.handleSessionExpiredEvent()
            case HubPayload.EventName.Auth.fetchSessionAPI:
                logInfo("[App] \(#function) Auth.fetchSessionAPI event occurred in AUTH channel")
                self.isSignedIn = self.checkIfUserSignedIn(payload.data)
            default:
                break
            }
        }
    }

    func checkIfUserSignedIn(_ data: Any?) -> Bool {
        guard let event = data as? AWSAuthFetchSessionOperation.OperationResult,
              case let .success(result) = event else {
            return false
        }
        guard let tokensProvider = result as? AuthCognitoTokensProvider,
              case let .failure(authError) = tokensProvider.getCognitoTokens() else {
            return result.isSignedIn
        }
        guard case .sessionExpired = authError else {
            return result.isSignedIn
        }
        return false
    }

    func handleSessionExpiredEvent() {
        listeners.forEach { listener in
            listener.listenAuthChannelEvents(event: .sessionExpired)
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
