import Foundation

// sourcery: AutoMockable
protocol MoreItemViewMappable {
    func mapSection(_ input: MoreSectionModel, hasUnseenFeedings: Bool) -> MoreSectionView
}

final class MoreItemViewMapper: MoreItemViewMappable {
    func mapSection(_ input: MoreSectionModel, hasUnseenFeedings: Bool) -> MoreSectionView {
        MoreSectionView(
            title: input.title,
            items: input.actions.map {
                mapActionModel($0, hasIndicator: $0.type == .feedings && hasUnseenFeedings)
            }
        )
    }

    private func mapActionModel(_ input: MoreActionModel, hasIndicator: Bool) -> MoreItemView {
        MoreItemView(
            identifier: input.type.rawValue,
            title: input.title,
            hasIndicator: hasIndicator
        )
    }
}

struct MoreSectionView {
    let title: String?
    let items: [MoreItemView]
}

struct MoreItemView {
    let identifier: String
    let title: String
    let hasIndicator: Bool
}
