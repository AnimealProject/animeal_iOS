import UIKit
import Common
@MainActor

final class AttachPhotoAssembler {
    private let pointId: String
    private let coordinator: AttachPhotoCoordinatable & AttachPhotoCoordinatorEventHandlerProtocol

    // MARK: - Initialization
    init(pointId: String, coordinator: AttachPhotoCoordinatable & AttachPhotoCoordinatorEventHandlerProtocol ) {
        self.pointId = pointId
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = AttachPhotoModel(pointId: pointId)
        let viewModel = AttachPhotoViewModel(
            model: model,
            contentMapper: AttachPhotoViewMapper(),
            coordinator: coordinator)
        let view = AttachPhotoViewController(viewModel: viewModel)
        return view
    }
}
