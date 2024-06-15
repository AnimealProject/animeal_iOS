import Foundation

// SDK
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Services

final class UserValidationModel: UserProfileValidationModel {
    // MARK: - Private Properties
    private var listeners: [AuthChannelEventsListener] = []

    // MARK: - Accessible properties
    private(set) var isSignedIn = false
    private(set) var phoneNumberVerified = false
    private(set) var emailVerified = false
    private(set) var areAllNecessaryFieldsFilled = false

    // MARK: - Initialization
    init() {
        listenAuthChannelMessages()
    }

    // MARK: - UserProfileValidationModel
    var validated: Bool { phoneNumberVerified && areAllNecessaryFieldsFilled }

    func handleUserAttributesEvent(_ attributes: [UserProfileAttribute]) {
        let attributes = attributes.reduce([UserProfileAttributeKey: String]()) { partialResult, attribute in
            var result = partialResult
            result[attribute.key] = attribute.value
            return result
        }

        phoneNumberVerified = attributes[.phoneNumberVerified]
            .map { Bool($0) ?? false } ?? false
        emailVerified = attributes[.emailVerified]
            .map { Bool($0) ?? false } ?? false

        areAllNecessaryFieldsFilled = [UserProfileAttributeKey.name, .familyName, .email, .phoneNumber]
            .allSatisfy { attributes[$0]?.isEmpty == false }
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
        guard let event = data as? Result<AuthSession, AuthError>,
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
}
