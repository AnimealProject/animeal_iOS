//
//  AdminDirectoryResponse.swift
//  animeal
//
//  Created by Giorgi Amiranashvili on 23.03.26.
//

import Foundation

struct ListUsersInGroupResponse: Decodable {
    let users: [ModerationDirectoryUserResponse]
    
    enum CodingKeys: String, CodingKey {
        case users = "Users"
    }
}

struct ModerationDirectoryUserAttributeResponse: Decodable {
    let name: String
    let value: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case value = "Value"
    }
}

struct ModerationDirectoryUserResponse: Decodable {
    let username: String
    let userAttributes: [ModerationDirectoryUserAttributeResponse]
    
    enum CodingKeys: String, CodingKey {
        case username = "Username"
        case userAttributes = "UserAttributes"
        case attributes = "Attributes"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        username = try container.decode(String.self, forKey: .username)
        
        if let attributes = try container.decodeIfPresent([ModerationDirectoryUserAttributeResponse].self, forKey: .userAttributes) {
            userAttributes = attributes
        } else {
            userAttributes = try container.decodeIfPresent([ModerationDirectoryUserAttributeResponse].self, forKey: .attributes) ?? []
        }
    }
}
