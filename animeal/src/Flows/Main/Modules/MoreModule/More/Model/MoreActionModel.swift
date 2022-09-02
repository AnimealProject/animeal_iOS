import Foundation

struct MoreActionModel {
    let type: MoreActionType
    let title: String
}

enum MoreActionType: String {
    case profilePage
    case donate
    case help
    case about
    case account
}
