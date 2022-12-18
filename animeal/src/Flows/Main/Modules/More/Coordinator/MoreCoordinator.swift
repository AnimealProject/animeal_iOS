import Foundation
import UIKit
import UIComponents

@MainActor
final class MoreCoordinator: Coordinatable {
    // MARK: - Dependencies
    private var _navigator: Navigating
    private let completion: ((HomeFlowBackwardEvent?) -> Void)?
    private var backwardEvent: HomeFlowBackwardEvent?
    
    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        navigator: Navigator,
        completion: ((HomeFlowBackwardEvent?) -> Void)? = nil
    ) {
        self._navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let moreViewController = MoreModuleAssembler(coordinator: self).assemble()
        _navigator.push(moreViewController, animated: false, completion: nil)
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
            self._navigator.present(
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
        case .faq:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.faq)
        case .about:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.about)
        case .account:
            viewController = MorePartitionModuleAssembler(coordinator: self).assemble(.account)
        }
        _navigator.navigationController?.customTabBarController?.setTabBarHidden(true, animated: true)
        _navigator.navigationController?.setNavigationBarHidden(false, animated: false)
        _navigator.push(viewController, animated: true, completion: nil)
    }
}

extension MoreCoordinator: MorePartitionCoordinatable {
    func routeTo(_ route: MorePartitionRoute) {
        switch route {
        case .logout:
            backwardEvent = HomeFlowBackwardEvent.event(
                .shouldShowToast(L10n.Toast.successLogout)
            )
            stop()
        case .deleteUser:
            backwardEvent = HomeFlowBackwardEvent.event(
                .shouldShowToast(L10n.Toast.userDeleted)
            )
            stop()
        case .back:
            _navigator.pop(animated: true, completion: nil)
        case .error(let errorDescription):
            presentError(errorDescription)
        }
    }
}

extension MoreCoordinator: VerificationCoordinatable {
    func moveFromVerification(to route: VerificationRoute) {
        switch route {
        case .fillProfile:
            _navigator.pop(animated: true, completion: nil)
        }
    }
}

extension MoreCoordinator: ProfileCoordinatable {
    func move(to route: ProfileRoute) {
        switch route {
        case .done:
            _navigator.pop(animated: true, completion: nil)
        case .cancel:
            _navigator.pop(animated: true, completion: nil)
        case let .confirm(details, attribute):
            let viewController = VerificationAfterProfileAuthAssembler.assembly(
                coordinator: self,
                deliveryDestination: details.destination,
                attribute: VerificationModelAttribute(
                    key: VerificationModelAttributeKey(userAttributeKey: attribute.key),
                    value: attribute.value
                )
            )
            _navigator.push(viewController, animated: true, completion: nil)
        case .picker(let make):
            guard let viewController = make() else { return }
            _navigator.present(viewController, animated: false, completion: nil)
        case .dismiss:
            if let bottomSheetVC = _navigator.topViewController as? BottomSheetPresentationController {
                bottomSheetVC.dismissView(completion: nil)
            }
        }
    }
}
