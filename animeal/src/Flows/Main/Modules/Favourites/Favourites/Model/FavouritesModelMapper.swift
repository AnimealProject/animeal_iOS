import Foundation

// sourcery: AutoMockable
protocol FavouriteModelMappable {
    func mapFavourite(_ input: FullFeedingPoint) -> FavouritesModel.FavouriteContent
}

final class FavouriteModelMapper: FavouriteModelMappable {
    func mapFavourite(_ item: FullFeedingPoint) -> FavouritesModel.FavouriteContent {
        return FavouritesModel.FavouriteContent(
            feedingPointId: item.feedingPoint.id,
            header: FavouritesModel.Header(
                cover: item.feedingPoint.cover,
                title: item.feedingPoint.localizedName.removeHtmlTags()
            ),
            status: convertStatus(item.feedingPoint.status),
            isHighlighted: true
        )
    }

    private func convertStatus(_ status: FeedingPointStatus) -> FavouritesModel.Status {
        switch status {
        case .fed:
            return .success(L10n.Feeding.Status.fed)
        case .starved:
            return .error(L10n.Feeding.Status.starved)
        case .pending:
            return .attention(L10n.Feeding.Status.inprogress)
        }
    }
}
