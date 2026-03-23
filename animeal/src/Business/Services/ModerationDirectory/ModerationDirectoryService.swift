//
//  ModerationDirectoryService.swift
//  animeal
//
//  Created by Giorgi Amiranashvili on 22.03.26.
//

import Foundation
import Common
import Amplify

protocol ModerationDirectoryServiceHolder {
    var moderationDirectoryService: ModerationDirectoryServiceProtocol { get }
}

protocol ModerationDirectoryServiceProtocol: AnyObject {
    func fetchModeratorsAndAdmins() async throws -> [ModerationDirectoryUser]
}

struct ModerationDirectoryUser: Hashable {
    let id: String
    let name: String
}

final class ModerationDirectoryService: ModerationDirectoryServiceProtocol {
    private enum Constants {
        static let apiName = "AdminQueries"
        static let listUsersInGroupPath = "/listUsersInGroup"
        static let moderatorGroup = "Moderator"
        static let administratorGroup = "Administrator"
    }
    
    func fetchModeratorsAndAdmins() async throws -> [ModerationDirectoryUser] {
        async let moderators = fetchUsersInGroup(Constants.moderatorGroup)
        async let admins = fetchUsersInGroup(Constants.administratorGroup)
        let merged = try await moderators + admins
        /// remove duplicates by id
        var seen = Set<String>()
        return merged.filter { user in
            seen.insert(user.id).inserted
        }
    }
    
    private func fetchUsersInGroup(_ groupName: String) async throws -> [ModerationDirectoryUser] {
        do {
            let request = RESTRequest(
                apiName: Constants.apiName,
                path: Constants.listUsersInGroupPath,
                queryParameters: ["groupname": groupName]
            )
            let data = try await Amplify.API.get(request: request)
            let response = try JSONDecoder().decode(ListUsersInGroupResponse.self, from: data)
            return response.users.map { $0.toDomain() }
        } catch {
            throw mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> BaseError {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return BaseError(error: nsError)
        }
        return L10n.Errors.somethingWrong.asBaseError(
            failureReason: error.localizedDescription,
            code: .unknown
        )
    }
}

private extension Array where Element == ModerationDirectoryUserAttributeResponse {
    func value(for key: String) -> String? {
        first(where: { $0.name == key })?.value
    }
}

private extension ModerationDirectoryUserResponse {
    func toDomain() -> ModerationDirectoryUser {
        let firstName = userAttributes.value(for: "name") ?? ""
        let lastName = userAttributes.value(for: "family_name") ?? ""
        let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return ModerationDirectoryUser(
            id: username,
            name: fullName.isEmpty ? "Unknown" : fullName
        )
    }
}
