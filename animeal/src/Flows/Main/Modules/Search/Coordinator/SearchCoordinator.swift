// System
import UIKit

// SDK
import UIComponents
import Style

final class SearchCoordinator: Coordinatable {
    // MARK: - Dependencies
    private let navigator: Navigating
    private let completion: (() -> Void)?
    private var bottomSheetController: BottomSheetPresentationController?

    // MARK: - Initialization
    init(
        navigator: Navigator,
        completion: (() -> Void)? = nil
    ) {
        self.navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let viewController = SearchAssembler.assembly(coordinator: self)
        navigator.push(viewController, animated: false, completion: nil)
    }

    func stop() {
        completion?()
    }
}

extension SearchCoordinator: SearchCoordinatable {
    func move(to route: SearchRoute) {
        switch route {
        case .details(let identifier):
            let viewController = FeedingPointDetailsModuleAssembler(
                coordinator: self,
                pointId: identifier
            ).assemble()
            let controller = BottomSheetPresentationController(controller: viewController)
            controller.modalPresentationStyle = .overFullScreen
            navigator.present(controller, animated: false, completion: nil)
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
                self.navigator.present(screen, animated: true, completion: nil)
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
            navigator.topViewController?.dismiss(animated: true, completion: nil)
        case .cancel:
            navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
