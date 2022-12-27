import UIKit
import Style
import UIComponents

protocol FavouriteViewItemMappable {
    func mapFavourite(_ input: FavouritesModel.FavouriteContent) -> FavouriteItem
    func mapShimmerViewItem(_ input: FavouriteShimmerViewItem) -> FavouriteItem
    func mapFeedingPointMediaContent(_ feedingPointId: String, _ input: Data?) -> FavouriteMediaContent?
}

final class FavouriteViewItemMapper: FavouriteViewItemMappable {
    func mapFavourite(_ input: FavouritesModel.FavouriteContent) -> FavouriteItem {
        return FavouriteViewItem(
            feedingPointId: input.feedingPointId,
            placeInfo: PlaceInfoView.Model(
                icon: Asset.Images.placeCoverPlaceholder.image,
                title: input.header.title,
                status: convert(input.status)),
            isHighlighted: input.isHighlighted)
    }
    
    func mapShimmerViewItem(_ input: FavouriteShimmerViewItem) -> FavouriteItem {
        return FavouriteShimmerViewItem(scheduler: input.scheduler)
    }
    
    func mapFeedingPointMediaContent(_ feedingPointId: String, _ input: Data?) -> FavouriteMediaContent? {
        guard let data = input, let icon = UIImage(data: data) else { return nil }
        return FavouriteMediaContent(feedingPointId: feedingPointId, favouriteIcon: icon)
    }
    
    private func convert(_ status: FavouritesModel.Status) -> StatusView.Model {
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
