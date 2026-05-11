// System
import UIKit

// SDK
import UIComponents
import Style

final class HomeCoordinator: Coordinatable, HomeCoordinatorEventHandlerProtocol, GuestAlertCoordinatable {
    // MARK: - Dependencies
    private let _navigator: Navigating
    private let completion: (() -> Void)?
    private var bottomSheetController: UIViewController?

    let activityPresenter = ActivityIndicatorPresenter()

    // MARK: - Navigator
    var navigator: Navigating { _navigator }

    // MARK: - Home coordinator events
    var feedingDidStartedEvent: ((FeedingPointFeedDetails) -> Void)?
    var feedingDidFinishEvent: (([String]) -> Void)?
    var moveToFeedingPointEvent: ((String) -> Void)?
    var needsAuthenticationEvent: (() -> Void)?

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
    @MainActor
    func routeTo(_ route: HomeRoute) {
        switch route {
        case .details(let pointId):
            let viewController = FeedingPointDetailsModuleAssembler(
                coordinator: self,
                pointId: pointId,
                isOverMap: true
            ).assemble()

            viewController.modalPresentationStyle = .pageSheet

            if let sheet = viewController.sheetPresentationController {
                let initialDetent = UISheetPresentationController.Detent.custom(
                    identifier: .init("initial")
                ) { _ in 240 }
                sheet.detents = [initialDetent, .medium(), .large()]
                sheet.selectedDetentIdentifier = .init("initial")
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 16
                sheet.largestUndimmedDetentIdentifier = nil
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                viewController.isModalInPresentation = false
            }

            _navigator.present(viewController, animated: true, completion: nil)
            bottomSheetController = viewController
        case .attachPhoto(let pointId):
            let attachPhotoCoordinator = AttachPhotoCoordinator(
                pointId: pointId,
                coordinator: self,
                completion: nil)
            attachPhotoCoordinator.start()
        case .feedingComplete:
            let viewController = FeedingFinishedModuleAssembler(coordinator: self).assemble()
            viewController.modalPresentationStyle = .overFullScreen
            navigator.present(viewController, animated: true, completion: nil)
        case .feedingTrustedComplete:
            let viewController = FeedingFinishedModuleAssembler(coordinator: self).assemble()
            viewController.modalPresentationStyle = .overFullScreen
            navigator.present(viewController, animated: true, completion: nil)
        }
    }
}

extension HomeCoordinator: FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute) {
        switch route {
        case .feed(let feedingDetails):
            let screen = FeedingBookingModuleAssembler(
                coordinator: self,
                feedingDetails: feedingDetails
            ).assemble()
            screen.modalPresentationStyle = .overFullScreen
            bottomSheetController?.present(screen, animated: true)
        case .map: break
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
            bottomSheetController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension HomeCoordinator: AttachPhotoCompleteCoordinatable {
    func routeTo(_ route: AttachPhotoCompleteRoute) {
        switch route {
        case let .finishFeeding(imageKeys):
            feedingDidFinishEvent?(imageKeys)
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension HomeCoordinator: FeedingFinishedCoordinatable {
    func routeTo(_ route: FeedingFinishedRoute) {
        switch route {
        case .backToHome:
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
