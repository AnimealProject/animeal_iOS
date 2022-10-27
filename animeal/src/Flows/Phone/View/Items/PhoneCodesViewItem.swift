import UIKit

enum PhoneCodesViewItem: Hashable {
    case common(identifier: String, isSelected: Bool, flag: UIImage?, code: String)

    var identifier: String {
        switch self {
        case let .common(identifier, _, _, _):
            return identifier
        }
    }
}

struct PhoneCodesViewHeader {
    let title: String
}
