import UIComponents
import Style

// sourcery: AutoMockable
protocol FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem
}

final class FeedingPointDetailsViewMapper: FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem {
        let feeders = input.content.feeders.map { feeder in
            FeedingPointFeeders.Feeder(name: feeder.name,lastFeeded: feeder.lastFeeded)
        }

        return FeedingPointDetailsViewItem(
            // TODO: fix icon and  status with real data
            placeInfo: PlaceInfoView.Model(
                icon: Asset.Images.cityLogo.image,
                title: input.content.header.title,
                status: StatusModel(status: .attention("There is no food"))
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
