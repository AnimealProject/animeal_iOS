// System
import Foundation

// SDK
import UIComponents

protocol AlertCoordinatable: AnyObject {
    @MainActor
    func displayAlert(_ alert: ViewAlert)
}

extension AlertCoordinatable {
    @MainActor
    func displayAlert(message: String) {
        let viewAlert = ViewAlert(
            title: message,
            actions: [.ok()]
        )
        displayAlert(viewAlert)
    }
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
        DispatchQueue.main.async {
            self.navigator.present(
                alertViewController,
                animated: true,
                completion: nil
            )
        }
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

extension ViewAlertAction {
    static func ok(handler: @escaping () -> Void = { }) -> Self {
        ViewAlertAction(
            title: L10n.Action.ok,
            style: .accent,
            handler: handler
        )
    }
    
    static func yes(handler: @escaping () -> Void = { }) -> Self {
        ViewAlertAction(
            title: L10n.Action.yes,
            style: .accent,
            handler: handler
        )
    }
    
    static func no(handler: @escaping () -> Void = { }) -> Self {
        ViewAlertAction(
            title: L10n.Action.no,
            style: .inverted,
            handler: handler
        )
    }
}
