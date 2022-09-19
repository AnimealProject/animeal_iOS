// System
import UIKit

// SDK
import UIComponents
import Style

final class HomeCoordinator: Coordinatable {
    // MARK: - Dependencies
    private let navigator: Navigating
    private let completion: (() -> Void)?

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
        let moreViewController = HomeModuleAssembler(coordinator: self).assemble()
        navigator.push(moreViewController, animated: false, completion: nil)
    }

    func stop() {
        completion?()
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

extension HomeCoordinator: HomeCoordinatable {
    func routeTo(_ route: HomeRoute) {
        switch route {
        case .details:
            // TODO: Fix transitionController height
            let transition = CurtainTransitionController(detent: TransitionDetent.custom(315))
            let view = FeedingPointDetailsModuleAssembler(coordinator: self).assemble()
            view.transitioningDelegate = transition
            view.modalPresentationStyle = .custom
            navigator.present(view, animated: true, completion: nil)
        }
    }
}

extension HomeCoordinator: FeedingPointCoordinatable {
    func routeTo(_ route: FeedingPointRoute) {
        switch route {
        case .dismiss:
            navigator.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
