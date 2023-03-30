// System
import Foundation

// SDK
import Services
import Amplify

final class UserProfileService: UserProfileServiceProtocol {
    // MARK: - Private properties
    private let converter: UserProfileAmplifyConverting & AmplifyUserProfileConverting
    private let userValidationModel: UserProfileValidationModel
    private var cachedUserNames: [String: String]?
    private var userNamesNextToken: String?

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

    func fetchUserNames(for userIds: [String]) async throws -> [String: String] {
        if let cachedUserNames = cachedUserNames, userIds.allSatisfy({ cachedUserNames.keys.contains($0) }) {
            return cachedUserNames
        }
        let path = "/listUsers"
        do {
            cachedUserNames = [:]
            var userNames: [String: String] = [:]
            var nextToken: String? = userNamesNextToken ?? ""
            while nextToken != nil {
                var query: [String: String] = ["limit": "60"]
                if let nextToken = nextToken, !nextToken.isEmpty {
                    query["token"] = nextToken.urlPercentEncoding()
                }
                let request = RESTRequest(path: path, queryParameters: query, body: nil)
                let result = try await Amplify.API.get(request: request)
                let list: UserList = try JSONDecoder().decode(responseBody: result)
                let userNamesBatch: [String: String] = list.users.reduce(into: [:]) { dict, item in
                    dict[item.id] = item.fullUserName
                }

                userNames.merge(userNamesBatch, uniquingKeysWith: { _, new in new })
                cachedUserNames = userNames

                nextToken = list.nextToken
                userNamesNextToken = nextToken
            }
            return userNames
        } catch {
            throw UserProfileError.unknown("Something went wrong.")
        }
    }

    private struct UserList: Decodable {
        let users: [UserListItem]
        let nextToken: String?

        private enum CodingKeys: String, CodingKey {
            case users = "Users"
            case nextToken = "NextToken"
        }
    }

    private struct UserListItem: Decodable {
        let id: String
        let attributes: [String: String]

        private enum CodingKeys: String, CodingKey {
            case id = "Username"
            case attributes = "Attributes"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(String.self, forKey: .id)

            var attributesContainer = try container.nestedUnkeyedContainer(forKey: .attributes)
            var attributes: [String: String] = [:]
            while !attributesContainer.isAtEnd {
                guard let item = try? attributesContainer.decode([String: String].self),
                      let name = item["Name"], let value = item["Value"] else {
                    continue
                }
                attributes[name] = value
            }
            self.attributes = attributes
        }

        var fullUserName: String {
            let firstName = attributes["name"]
            let lastName = attributes["family_name"]
            return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
        }
    }
}
