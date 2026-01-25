import Foundation
import Combine

// SDK
import Amplify
import AWSCognitoAuthPlugin
import AWSPluginsCore
import Services

final class UserValidationModel: UserProfileValidationModel {
    // MARK: - Private Properties
    private var listeners = [AuthChannelEventsListener]()
    private let userModeSubject = CurrentValueSubject<UserMode?, Never>(nil)
    private let userRoleSubject = CurrentValueSubject<Set<UserRole>, Never>([])
    
    // MARK: - Accessible properties
    private(set) var isSignedIn = false
    private(set) var userMode: UserMode? {
        didSet {
            userModeSubject.send(userMode)
        }
    }
    private(set) var roles: Set<UserRole> = [] {
        didSet {
            userRoleSubject.send(roles)
        }
    }
    private(set) var phoneNumberVerified = false
    private(set) var emailVerified = false
    private(set) var areAllNecessaryFieldsFilled = false
    
    // MARK: - Publishers
    var userModePublisher: AnyPublisher<UserMode?, Never> {
        userModeSubject.eraseToAnyPublisher()
    }
    
    var userRolePublisher: AnyPublisher<Set<UserRole>, Never> {
        userRoleSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    init() {
        listenAuthChannelMessages()
    }

    // MARK: - UserProfileValidationModel
    var validated: Bool {
        guard userMode != .guest else {
            return true
        }

        return phoneNumberVerified && areAllNecessaryFieldsFilled
    }

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

    func set(userMode: UserMode?) {
        self.userMode = userMode
    }

    func reset() {
        isSignedIn = false
        userMode = nil
        phoneNumberVerified = false
        emailVerified = false
        areAllNecessaryFieldsFilled = false
        roles = []
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
                self.roles = []
            case HubPayload.EventName.Auth.fetchUserAttributesAPI:
                logInfo("[App] \(#function) Auth.fetchUserAttributesAPI event occurred in AUTH channel")
            case HubPayload.EventName.Auth.sessionExpired:
                logInfo("[App] \(#function) Auth.sessionExpired event occurred in AUTH channel")
                self.isSignedIn = false
                self.roles = []
                self.handleSessionExpiredEvent()
            case HubPayload.EventName.Auth.fetchSessionAPI:
                logInfo("[App] \(#function) Auth.fetchSessionAPI event occurred in AUTH channel")
                self.isSignedIn = self.checkIfUserSignedIn(payload.data)
                if !self.isSignedIn {
                    self.roles = []
                } else {
                    self.updateRolesFromSessionData(payload.data)
                }
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

private extension UserValidationModel {
    /// Updates user roles from Cognito group claims (`cognito:groups`) in the ID token using the current auth session.
    func updateRolesFromSessionData(_ data: Any?) {
        guard let event = data as? Result<AuthSession, AuthError>,
              case let .success(session) = event,
              let tokens = try? (session as? AuthCognitoTokensProvider)?.getCognitoTokens().get(),
              let claims = try? AWSAuthService().getTokenClaims(tokenString: tokens.idToken).get()
        else {
            roles = []
            return
        }
        
        let groups = (claims["cognito:groups"] as? [String]) ?? []
        let normalized = Set(groups.map { $0.lowercased() })
        
        var newRoles = Set<UserRole>()
        if normalized.contains("administrator") { newRoles.insert(.admin) }
        if normalized.contains("moderator") { newRoles.insert(.moderator) }
        if normalized.contains("volunteer") { newRoles.insert(.volunteer) }
        
        if roles != newRoles {
            roles = newRoles
        }
    }
}
