import UIKit
import Common
@MainActor

final class AttachPhotoAssembler {
    private let pointId: String

    init(pointId: String) {
        self.pointId = pointId
    }

    func assemble() -> UIViewController {
        let model = AttachPhotoModel(pointId: pointId)
        let viewModel = AttachPhotoViewModel(
            model: model,
            contentMapper: AttachPhotoViewMapper(),
            completion: nil)
        
        let view = AttachPhotoViewController(viewModel: viewModel)
        return view
    }
}
