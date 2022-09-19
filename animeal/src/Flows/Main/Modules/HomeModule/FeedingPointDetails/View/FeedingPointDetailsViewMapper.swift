import UIComponents
import Style

// sourcery: AutoMockable
protocol FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem
}

final class FeedingPointDetailsViewMapper: FeedingPointDetailsViewMappable {
    func mapFeedingPoint(_ input: FeedingPointDetailsModel.PointContent) -> FeedingPointDetailsViewItem {

        return FeedingPointDetailsViewItem(
            // TODO: fix icon and  status with real data
            placeInfo: PlaceInfoView.Model(
                icon: Asset.Images.cityLogo.image,
                title: input.content.header.title,
                status: StatusModel(status: .attention("There is no food"))
            ),
            placeDescription: .init(title: input.content.description.text),
            action: ButtonView.Model(
                identifier: input.action.identifier,
                viewType: ButtonView.self,
                title: input.action.title
            )
        )
    }
}

struct FeedingPointDetailsViewItem {
    let placeInfo: PlaceInfoView.Model
    let placeDescription: TextParagraphView.Model
    let action: ButtonView.Model
}
