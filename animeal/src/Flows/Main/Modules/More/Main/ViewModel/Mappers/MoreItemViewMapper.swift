import Foundation

// sourcery: AutoMockable
protocol MoreItemViewMappable {
    func mapActionModel(_ input: MoreActionModel, hasIndicator: Bool) -> MoreItemView
}

final class MoreItemViewMapper: MoreItemViewMappable {
    func mapActionModel(_ input: MoreActionModel, hasIndicator: Bool) -> MoreItemView {
        return MoreItemView(
            identifier: input.type.rawValue,
            title: input.title,
            hasIndicator: hasIndicator
        )
    }
}

struct MoreItemView {
    let identifier: String
    let title: String
    let hasIndicator: Bool
}
