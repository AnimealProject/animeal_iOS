import UIComponents
import Style
import UIKit

// sourcery: AutoMockable
protocol FeedingPointDetailsViewMappable {
    func mapFeedingPoint(
        _ input: FeedingPointDetailsModel.PointContent
    ) -> FeedingPointDetailsViewMapper.FeedingPointDetailsViewItem
    func mapFeedingPointMediaContent(
        _ input: Data?
    ) -> FeedingPointDetailsViewMapper.FeedingPointMediaContent?
    func mapFeedingHistory(
        _ input: [FeedingPointDetailsModel.Feeder]
    ) -> FeedingPointDetailsViewMapper.FeedingPointFeeders
}

final class FeedingPointDetailsViewMapper: FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem {
        let feeders = input.content.feeders.map { feeder in
            FeedingPointFeeders.Feeder(name: feeder.name, lastFeeded: feeder.lastFeeded)
        }

        return FeedingPointDetailsViewItem(
            placeInfo: PlaceInfoView.Model(
                icon: .image(Asset.Images.placeCoverPlaceholder.image),
                title: input.content.header.title,
                status: convert(input.content.status)
            ),
            isFavorite: input.content.isFavorite,
            placeDescription: TextParagraphView.Model(title: input.content.description.text),
            action: Action(
                model: ButtonView.Model(
                    identifier: input.action.identifier,
                    viewType: ButtonView.self,
                    title: input.action.title
                ),
                isEnabled: input.action.isEnabled
            ),
            feedingPointFeeders: FeedingPointFeeders(
                title: L10n.Text.Header.lastFeeder,
                feeders: feeders
            )
        )
    }

    func mapFeedingPointMediaContent(_ input: Data?) -> FeedingPointMediaContent? {
        guard let data = input, let icon = UIImage(data: data) else { return nil }
        return FeedingPointMediaContent(pointDetailsIcon: icon)
    }

    func mapFeedingHistory(
        _ input: [FeedingPointDetailsModel.Feeder]
    ) -> FeedingPointFeeders {
        let feeders = input.map { feeder in
            FeedingPointFeeders.Feeder(name: feeder.name, lastFeeded: feeder.lastFeeded)
        }
        return FeedingPointFeeders(
            title: L10n.Text.Header.lastFeeder,
            feeders: feeders
        )
    }

    private func convert(_ status: FeedingPointDetailsModel.Status) -> StatusView.Model {
        switch status {
        case .attention(let message):
            return StatusView.Model(status: StatusView.Status.attention(message))
        case .success(let message):
            return StatusView.Model(status: StatusView.Status.success(message))
        case .error(let message):
            return StatusView.Model(status: StatusView.Status.error(message))
        }
    }
}

extension FeedingPointDetailsViewMapper {
    struct FeedingPointDetailsViewItem {
        let placeInfo: PlaceInfoView.Model
        let isFavorite: Bool
        let placeDescription: TextParagraphView.Model
        let action: Action
        let feedingPointFeeders: FeedingPointFeeders
    }

    struct FeedingPointFeeders {
        let title: String
        let feeders: [Feeder]

        struct Feeder {
            let name: String
            let lastFeeded: String
        }
    }

    struct FeedingPointMediaContent {
        var pointDetailsIcon: UIImage
    }

    struct Action {
        let model: ButtonView.Model
        let isEnabled: Bool
    }
}
