import UIKit
import Foundation
import UIComponents

@MainActor
final class FavouritesCoordinator: Coordinatable {

    // MARK: - Dependencies
    internal var navigator: Navigating
    private let completion: ((HomeFlowBackwardEvent?) -> Void)?
    private let switchFlowAction: ((MainFlowSwitchAction) -> Void)?
    private var backwardEvent: HomeFlowBackwardEvent?
    private var bottomSheetController: BottomSheetPresentationController?

    // MARK: - Initialization
    init(
        navigator: Navigator,
        switchFlowAction: ((MainFlowSwitchAction) -> Void)? = nil,
        completion: ((HomeFlowBackwardEvent?) -> Void)? = nil
    ) {
        self.navigator = navigator
        self.switchFlowAction = switchFlowAction
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let favouritesViewController = FavouritesModuleAssembler(coordinator: self).assemble()
        navigator.push(favouritesViewController, animated: false, completion: nil)
    }

    func stop() {
        completion?(backwardEvent)
    }

    private func presentError(_ error: String) {
        let alertViewController = AlertViewController(title: error)
        alertViewController.addAction(
            AlertAction(title: L10n.Action.ok, style: .accent) {
                alertViewController.dismiss(animated: true)
            }
        )
        DispatchQueue.main.async {
            self.navigator.present(
                alertViewController,
                animated: true,
                completion: nil
            )
        }
    }
}

extension FavouritesCoordinator: FavouritesCoordinatable {
    func routeTo(_ route: FavouritesRoute) {
        switch route {
        case .details(let pointId):
            let viewController = FeedingPointDetailsModuleAssembler(
                coordinator: self,
                pointId: pointId,
                isOverMap: false
            ).assemble()
            let controller = BottomSheetPresentationController(
                controller: viewController,
                configuration: .fullScreen
            )
            controller.modalPresentationStyle = .overFullScreen
            navigator.present(controller, animated: false, completion: nil)
            bottomSheetController = controller
        }
    }
}

extension FavouritesCoordinator: FeedingPointCoordinatable {
    var isOverMap: Bool { false }
    
    func routeTo(_ route: FeedingPointRoute) {
        switch route {
        case .feed(let feedingDetails):
            bottomSheetController?.dismissView { [weak self] in
                guard let self else { return }
                let screen = FeedingBookingModuleAssembler(
                    coordinator: self, feedingDetails: feedingDetails
                ).assemble()
                screen.modalPresentationStyle = .overFullScreen
                self.navigator.present(screen, animated: true, completion: nil)
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

extension FavouritesCoordinator: FeedingBookingCoordinatable {
    func routeTo(_ route: FeedingBookingRoute) {
        switch route {
        case .cancel:
            navigator.topViewController?.dismiss(animated: true, completion: nil)
        case .agree(_):
            // TODO: Build the route to home screen
            navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
