// System
import UIKit

// SDK
import UIComponents
import Style

final class AttachPhotoCoordinator: Coordinatable, AttachPhotoCoordinatorEventHandlerProtocol {
    // MARK: - Dependencies
    private let pointId: String
    private let _navigator: Navigating
    private let completion: (() -> Void)?

    var navigator: Navigating { _navigator }

    // MARK: - AttachPhoto coordinator events
    var deletePhotoEvent: (() -> Void)?

    // MARK: - Initialization
    init(
        pointId: String,
        navigator: Navigating,
        completion: (() -> Void)? = nil
    ) {
        self.pointId = pointId
        self._navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let viewController = AttachPhotoAssembler(
            pointId: pointId, coordinator: self).assemble()
        let controller = BottomSheetPresentationController(
            controller: viewController,
            configuration: .attachPhotoScreen)
        controller.modalPresentationStyle = .overFullScreen

        navigator.present(controller, animated: false, completion: nil)
    }

    func stop() {
        completion?()
    }
}

extension AttachPhotoCoordinator: AttachPhotoCoordinatable {
    func routeTo(_ route: AttachPhotoRoute) {
        switch route {
        case .deletePhoto(let image):
            let alertViewController = AlertViewController(
                title: L10n.Attach.Photo.Delete.message,
                image: image
            )
            alertViewController.addAction(
                AlertAction(title: L10n.Action.no, style: AlertAction.Style.inverted) { [weak alertViewController] in
                    alertViewController?.dismiss(animated: true)
                }
            )
            alertViewController.addAction(
                AlertAction(title: L10n.Action.yes, style: AlertAction.Style.accent) { [weak self] in
                    self?.deletePhotoEvent?()
                    alertViewController.dismiss(animated: true)
                }
            )
            DispatchQueue.main.async {
                self.navigator.topViewController?.present(
                    alertViewController,
                    animated: true,
                    completion: nil
                )
            }
        }
    }
}
