import UIKit
import Style

extension AttachPhotoView {
    public struct Model {
        public let placeTitle: String?
        public let placeImage: UIImage?
        public let hintTitle: String
        public let buttonTitle: String
        public let isActive: Bool

        public init(
            placeTitle: String?,
            placeImage: UIImage?,
            hintTitle: String,
            buttonTitle: String,
            isActive: Bool
        ) {
            self.placeTitle = placeTitle
            self.placeImage = placeImage
            self.hintTitle = hintTitle
            self.buttonTitle = buttonTitle
            self.isActive = isActive
        }
    }
}
