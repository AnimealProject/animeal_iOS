import UIKit

enum AttachPhotoViewActionEvent {
    case addImage(image: UIImage)
    case removeImage(image: UIImage)
    case finish
    case cameraAccess
}
