// System
import Foundation

// SDK
import Services

// swiftlint: disable cyclomatic_complexity
struct VerificationModelAttribute {
    let key: VerificationModelAttributeKey
    let value: String
}

enum VerificationModelAttributeKey: Hashable {
    case address
    case birthDate
    case email
    case familyName
    case gender
    case givenName
    case locale
    case middleName
    case name
    case nickname
    case phoneNumber
    case picture
    case preferredUsername
    case emailVerified
    case phoneNumberVerified
    case profile
    case sub
    case updatedAt
    case website
    case zoneInfo
    case custom(String)
    case unknown(String)
}

extension VerificationModelAttributeKey {
    init(userAttributeKey: AuthenticationUserAttributeKey) {
        switch userAttributeKey {
        case .address:
            self = .address
        case .birthDate:
            self = .birthDate
        case .email:
            self = .email
        case .familyName:
            self = .familyName
        case .gender:
            self = .gender
        case .givenName:
            self = .givenName
        case .locale:
            self = .locale
        case .middleName:
            self = .middleName
        case .name:
            self = .name
        case .nickname:
            self = .nickname
        case .phoneNumber:
            self = .phoneNumber
        case .picture:
            self = .picture
        case .preferredUsername:
            self = .preferredUsername
        case .custom(let string):
            self = .custom(string)
        case .unknown(let string):
            self = .unknown(string)
        case .emailVerified:
            self = .emailVerified
        case .phoneNumberVerified:
            self = .phoneNumberVerified
        case .profile:
            self = .profile
        case .sub:
            self = .sub
        case .updatedAt:
            self = .updatedAt
        case .website:
            self = .website
        case .zoneInfo:
            self = .zoneInfo
        }
    }

    var userAttributeKey: AuthenticationUserAttributeKey {
        switch self {
        case .address:
            return .address
        case .birthDate:
            return .birthDate
        case .email:
            return .email
        case .familyName:
            return .familyName
        case .gender:
            return .gender
        case .givenName:
            return .givenName
        case .locale:
            return .locale
        case .middleName:
            return .middleName
        case .name:
            return .name
        case .nickname:
            return .nickname
        case .phoneNumber:
            return .phoneNumber
        case .picture:
            return .picture
        case .preferredUsername:
            return .preferredUsername
        case .custom(let string):
            return .custom(string)
        case .unknown(let string):
            return .unknown(string)
        case .emailVerified:
            return .emailVerified
        case .phoneNumberVerified:
            return .phoneNumberVerified
        case .profile:
            return .profile
        case .sub:
            return .sub
        case .updatedAt:
            return .updatedAt
        case .website:
            return .website
        case .zoneInfo:
            return .zoneInfo
        }
    }
}
// swiftlint: enable cyclomatic_complexity
