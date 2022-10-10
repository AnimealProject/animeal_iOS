import Foundation
import UIKit
import UIComponents

@MainActor
final class MoreCoordinator: Coordinatable {
    // MARK: - Dependencies
    private var navigator: Navigating
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
        let moreViewController = MoreModuleAssembler(coordinator: self).assemble()
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

extension MoreCoordinator: MoreCoordinatable {
    func routeTo(_ route: MoreRoute) {
        var viewController: UIViewController
        switch route {
        case .profilePage:
            viewController = ProfileChangeableAssembler.assembly(coordinator: self)
        case .donate:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.donate)
        case .help:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.help)
        case .about:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.about)
        case .account:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.account)
        }
        navigator.navigationController?.customTabBarController?.setTabBarHidden(true, animated: true)
        navigator.navigationController?.setNavigationBarHidden(false, animated: false)
        navigator.push(viewController, animated: true, completion: nil)
    }
}

extension MoreCoordinator: MorePartitionCoordinatable {
    func routeTo(_ route: MorePartitionRoute) {
        switch route {
        case .logout:
            stop()
        case .back:
            navigator.pop(animated: true, completion: nil)
        case .error(let errorDescription):
            presentError(errorDescription)
        }
    }
}

extension MoreCoordinator: VerificationCoordinatable {
    func moveFromVerification(to route: VerificationRoute) {
        switch route {
        case .fillProfile:
            navigator.pop(animated: true, completion: nil)
        }
    }
}

extension MoreCoordinator: ProfileCoordinatable {
    func move(to route: ProfileRoute) {
        switch route {
        case .done:
            navigator.pop(animated: true, completion: nil)
        case .cancel:
            navigator.pop(animated: true, completion: nil)
        case .confirm(let details, let attribute):
            let viewController = VerificationAfterProfileAuthAssembler.assembly(
                coordinator: self,
                deliveryDestination: details.destination,
                attribute: VerificationModelAttribute(
                    key: VerificationModelAttributeKey(userAttributeKey: attribute.key),
                    value: attribute.value
                )
            )
            navigator.push(viewController, animated: true, completion: nil)
        }
    }
}
