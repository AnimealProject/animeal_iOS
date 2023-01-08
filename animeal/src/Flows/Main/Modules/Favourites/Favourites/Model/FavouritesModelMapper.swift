import Foundation

// sourcery: AutoMockable
protocol FavouriteModelMappable {
    func mapFavourite(_ input: animeal.Favourite) -> FavouritesModel.FavouriteContent
}

final class FavouriteModelMapper: FavouriteModelMappable {
    func mapFavourite(_ item: animeal.Favourite) -> FavouritesModel.FavouriteContent {
        return FavouritesModel.FavouriteContent(
                feedingPointId: item.feedingPointId,
                header: FavouritesModel.Header(
                    cover: item.feedingPoint.cover,
                    title: item.feedingPoint.localizedName.removeHtmlTags()
                ), status: convertStatus(item.feedingPoint.status), isHighlighted: true
            )
    }

    private func convertStatus(_ status: FeedingPointStatus) -> FavouritesModel.Status {
        switch status {
        case .fed:
            return .success(L10n.Feeding.Status.fed)
        case .starved:
            return .error(L10n.Feeding.Status.starved)
        case .pending:
            // TODO: fix time interval
            return .attention(L10n.Feeding.Status.Pending.pattern("12 Hours"))
        }
    }
}
