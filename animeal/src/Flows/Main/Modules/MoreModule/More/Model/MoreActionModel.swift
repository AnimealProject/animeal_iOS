import Foundation

struct MoreActionModel {
    let type: MoreActionType
    let title: String
}

enum MoreActionType: String {
    case profilePage
    case donate
    case faq
    case about
    case account
}
