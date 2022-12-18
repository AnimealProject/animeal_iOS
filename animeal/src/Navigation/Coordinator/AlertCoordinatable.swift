// System
import Foundation

// SDK
import UIComponents

protocol AlertCoordinatable: AnyObject {
    @MainActor
    func displayAlert(_ alert: ViewAlert)
}

extension AlertCoordinatable where Self: Coordinatable {
    @MainActor
    func displayAlert(_ alert: ViewAlert) {
        let alertViewController = AlertViewController(title: alert.title)
        alert.actions.forEach { action in
            alertViewController.addAction(
                AlertAction(
                    title: action.title,
                    style: .init(action.style)
                ) { [weak alertViewController] in
                    alertViewController?.dismiss(animated: true) {
                        action.handler()
                    }
                }
            )
        }
        navigator.present(
            alertViewController,
            animated: true,
            completion: nil
        )
    }
}

extension AlertAction.Style {
    init(_ input: ViewAlertAction.Style) {
        switch input {
        case .accent:
            self = .accent
        case .inverted:
            self = .inverted
        }
    }
}
