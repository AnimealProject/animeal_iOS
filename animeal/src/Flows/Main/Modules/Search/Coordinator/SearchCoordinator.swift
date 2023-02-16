// System
import UIKit

// SDK
import UIComponents
import Style

final class SearchCoordinator: Coordinatable {
    // MARK: - Dependencies
    private let _navigator: Navigating
    private let switchFlowAction: ((MainFlowSwitchAction) -> Void)?
    private let completion: (() -> Void)?
    private var bottomSheetController: BottomSheetPresentationController?

    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        navigator: Navigator,
        switchFlowAction: ((MainFlowSwitchAction) -> Void)?,
        completion: (() -> Void)? = nil
    ) {
        self._navigator = navigator
        self.switchFlowAction = switchFlowAction
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let viewController = SearchAssembler.assembly(coordinator: self)
        _navigator.push(viewController, animated: false, completion: nil)
    }

    func stop() {
        completion?()
    }
}

extension SearchCoordinator: SearchCoordinatable {
    @MainActor
    func move(to route: SearchRoute) {
        switch route {
        case .details(let identifier):
            let viewController = FeedingPointDetailsModuleAssembler(
                coordinator: self,
                pointId: identifier,
                isOverMap: false
            ).assemble()
            let controller = BottomSheetPresentationController(controller: viewController)
            controller.modalPresentationStyle = .overFullScreen
            _navigator.present(controller, animated: false, completion: nil)
            bottomSheetController = controller
        }
    }
}

extension SearchCoordinator: FeedingPointCoordinatable {    
    func routeTo(_ route: FeedingPointRoute) {
        switch route {
        case .feed(let feedingDetails):
            bottomSheetController?.dismissView { [weak self] in
                guard let self else { return }
                let screen = FeedingBookingModuleAssembler(
                    coordinator: self,
                    feedingDetails: feedingDetails
                ).assemble()
                screen.modalPresentationStyle = .overFullScreen
                self._navigator.present(screen, animated: true, completion: nil)
            }
        case .map(let pointIdentifier):
            bottomSheetController?.dismissView { [weak self] in
                self?.switchFlowAction?(
                    .shouldSwitchToMap(pointIdentifier: pointIdentifier)
                )
            }
        }
    }
}

extension SearchCoordinator: FeedingBookingCoordinatable {
    func routeTo(_ route: FeedingBookingRoute) {
        switch route {
        case .agree(let feedingDetails):
            // TODO: Route to home screen with `feedingDetails` and request to build the route
            print(feedingDetails)
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        case .cancel:
            _navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
