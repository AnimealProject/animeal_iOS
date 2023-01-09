import UIKit

enum AttachPhotoViewItem: Hashable {
    case common(image: UIImage)
}

struct AttachPhotoViewContent {
    let placeTitle: String?
    let placeImage: UIImage?
    let hintTitle: String
    let buttonTitle: String
    let isActive: Bool
}
