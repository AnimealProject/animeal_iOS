import Foundation

// sourcery: AutoMockable
protocol MoreItemViewMappable {
    func mapActionModel(_ input: MoreActionModel) -> MoreItemView
}

final class MoreItemViewMapper: MoreItemViewMappable {
    func mapActionModel(_ input: MoreActionModel) -> MoreItemView {
        return MoreItemView(
            identifier: input.type.rawValue,
            title: input.title
        )
    }
}

struct MoreItemView {
    let identifier: String
    let title: String
}
