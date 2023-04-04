import Foundation

struct ProfileViewConfiguration {
    let hidesBackButton: Bool
}

extension ProfileViewConfiguration {
    static var afterAuth: ProfileViewConfiguration {
        ProfileViewConfiguration(hidesBackButton: true)
    }

    static var fromMore: ProfileViewConfiguration {
        ProfileViewConfiguration(hidesBackButton: false)
    }
}
