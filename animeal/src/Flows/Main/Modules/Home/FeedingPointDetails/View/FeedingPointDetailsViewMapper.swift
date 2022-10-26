import UIComponents
import Style
import UIKit

// sourcery: AutoMockable
protocol FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem
    func mapFeedingPointMediaContent(_ input: Data?) -> FeedingPointMediaContent?
}

final class FeedingPointDetailsViewMapper: FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem {
        let feeders = input.content.feeders.map { feeder in
            FeedingPointFeeders.Feeder(name: feeder.name, lastFeeded: feeder.lastFeeded)
        }

        return FeedingPointDetailsViewItem(
            placeInfo: PlaceInfoView.Model(
                icon: Asset.Images.placeCoverPlaceholder.image,
                title: input.content.header.title,
                status: convert(input.content.status)
            ),
            placeDescription: TextParagraphView.Model(title: input.content.description.text),
            action: ButtonView.Model(
                identifier: input.action.identifier,
                viewType: ButtonView.self,
                title: input.action.title
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

struct FeedingPointDetailsViewItem {
    let placeInfo: PlaceInfoView.Model
    let placeDescription: TextParagraphView.Model
    let action: ButtonView.Model
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
