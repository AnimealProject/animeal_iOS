// System
import UIKit

// SDK
import UIComponents
import Style

final class HomeCoordinator: Coordinatable, HomeCoordinatorEventHandlerProtocol {
    // MARK: - Dependencies
    private let _navigator: Navigating
    private let completion: (() -> Void)?
    private var bottomSheetController: BottomSheetPresentationController?

    let activityPresenter = ActivityIndicatorPresenter()

    // MARK: - Navigator
    var navigator: Navigating { _navigator }

    // MARK: - Home coordinator events
    var feedingDidStartedEvent: ((FeedingPointFeedDetails) -> Void)?

    // MARK: - Initialization
    init(
        navigator: Navigator,
        completion: (() -> Void)? = nil
    ) {
        self._navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let moreViewController = HomeModuleAssembler(coordinator: self).assemble()
        _navigator.push(moreViewController, animated: false, completion: nil)
    }

    func stop() {
        completion?()
    }
}

extension HomeCoordinator: HomeCoordinatable {
    @MainActor func routeTo(_ route: HomeRoute) {
        switch route {
        case .details(let pointId):
            let viewController = FeedingPointDetailsModuleAssembler(
                coordinator: self,
                pointId: pointId
            ).assemble()
            let controller = BottomSheetPresentationController(controller: viewController)
            controller.modalPresentationStyle = .overFullScreen
            _navigator.present(controller, animated: false, completion: nil)
            bottomSheetController = controller
        case .attachPhoto(let pointId):
            let attachPhotoCoordinator = AttachPhotoCoordinator(
                pointId: pointId,
                navigator: _navigator,
                completion: nil)
            attachPhotoCoordinator.start()
        }
    }
}

extension HomeCoordinator: FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute) {
        switch route {
        case .feed(let feedingDetails):
            bottomSheetController?.dismissView {
                let screen = FeedingBookingModuleAssembler(
                    coordinator: self, feedingDetails: feedingDetails
                ).assemble()
                screen.modalPresentationStyle = .overFullScreen
                self._navigator.present(screen, animated: true, completion: nil)
            }
        }
    }
}

extension HomeCoordinator: FeedingBookingCoordinatable {
    func routeTo(_ route: FeedingBookingRoute) {
        switch route {
        case .cancel:
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        case .agree(let feedingPoint):
            feedingDidStartedEvent?(feedingPoint)
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
