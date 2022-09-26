// System
import Foundation

// SDK
import Services

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
        }
    }
}
