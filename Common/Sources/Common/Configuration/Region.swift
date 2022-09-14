import Foundation

public enum Region: String, Hashable, CaseIterable {
    case GE

    public static var `default`: Region { .GE }
}

extension Region {
    public var phoneNumberCode: String {
        switch self {
        case .GE:
            return "+995"
        }
    }

    public var phoneNumberDigitsCount: Int {
        switch self {
        case .GE:
            return 9
        }
    }
}
