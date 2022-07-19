import UIKit

public typealias AuthenticationPresentationAnchor = UIWindow
public typealias AuthenticationCustomAttributes = [AuthenticationCustomAttributesKey: String]

public enum AuthenticationCustomAttributesKey {
    case username
    case password
    case email
}

public enum AuthenticationProvider {
    case apple(AuthenticationPresentationAnchor)

    case facebook(AuthenticationPresentationAnchor)

    case custom(AuthenticationCustomAttributes)
}
