import Foundation

struct MoreActionModel {
    let type: MoreActionType
    let title: String
}

enum MoreActionType: String {
    case profilePage
    case faq
    case donate
    case about
    case termsAndConditions
    case privacyPolicy
    case account
}
