import UIComponents
import Style
import UIKit


protocol AttachPhotoViewMappable {
    func mapFeedingPoint(
        _ input: AttachPhotoModel.PointContent
    ) -> AttachPhotoViewMapper.PlaceInfo
    func mapFeedingPointMediaContent(
        _ input: Data?
    ) -> AttachPhotoViewMapper.AttachPhotoMediaContent?
}

final class AttachPhotoViewMapper: AttachPhotoViewMappable {
    func mapFeedingPoint(_ input: AttachPhotoModel.PointContent) -> PlaceInfo {
        return PlaceInfo(
            name: input.content.title,
            image: Asset.Images.placeCoverPlaceholder.image
        )
    }

    func mapFeedingPointMediaContent(_ input: Data?) -> AttachPhotoMediaContent? {
        guard let data = input, let icon = UIImage(data: data) else {
            return AttachPhotoMediaContent(placeIcon: Asset.Images.placeCoverPlaceholder.image)
        }
        return AttachPhotoMediaContent(placeIcon: icon)
    }
}

extension AttachPhotoViewMapper {
    struct PlaceInfo {
        let name: String
        let image: UIImage
    }

    struct AttachPhotoMediaContent {
        var placeIcon: UIImage
    }
}
