import Foundation

protocol AttachPhotoModelMapperProtocol {
    func map(_ item: FeedingPoint) -> AttachPhotoModel.PointContent
}

final class AttachPhotoModelMapper: AttachPhotoModelMapperProtocol {
    func map(_ item: FeedingPoint) -> AttachPhotoModel.PointContent {
        return  AttachPhotoModel.PointContent(
            content: AttachPhotoModel.Content(
                cover: item.cover,
                title: item.localizedName.removeHtmlTags()
            )
        )
    }
}
