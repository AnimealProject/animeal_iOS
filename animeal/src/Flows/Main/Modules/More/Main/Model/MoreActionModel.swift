import Foundation

struct MoreActionModel {
    let type: MoreActionType
    let title: String
}

enum MoreActionType: String {
    case profilePage
    case feedings
    case faq
    case donate
    case about
    case termsAndConditions
    case privacyPolicy
    case account
    case qaMenu
}
