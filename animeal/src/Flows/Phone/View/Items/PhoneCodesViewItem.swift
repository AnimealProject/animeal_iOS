import UIKit

enum PhoneCodesViewItem: Hashable {
    struct Parameters: Hashable {
        let identifier: String
        let isSelected: Bool
        let flag: UIImage?
        let code: String
        let countryName: String
    }

    case common(Parameters)

    var identifier: String {
        switch self {
        case let .common(parameters):
            return parameters.identifier
        }
    }
}

struct PhoneCodesViewHeader {
    let title: String
}
