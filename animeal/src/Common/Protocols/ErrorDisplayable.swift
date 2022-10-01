import UIKit

import UIComponents

@MainActor
protocol ErrorDisplayable: AnyObject {
    func displayError(_ message: String, icon: UIImage?)
}

@MainActor
protocol ErrorDisplayCompatible: AnyObject {
    var onErrorIsNeededToDisplay: ((String) -> Void)? { get set }
}

extension ErrorDisplayable where Self: UIViewController {
    func displayError(_ message: String, icon: UIImage?) {
        let alertController = AlertViewController(title: message, image: icon)
        alertController.addAction(
            .ok { [weak self] in self?.dismiss(animated: true) }
        )

        present(alertController, animated: true)
    }

    func displayError(_ message: String) {
        let alertController = AlertViewController(title: message, image: nil)
        alertController.addAction(
            .ok { [weak self] in self?.dismiss(animated: true) }
        )

        present(alertController, animated: true)
    }
}

extension AlertAction {
    static func ok(handler: (() -> Void)? = nil) -> Self {
        AlertAction(
            title: L10n.Action.ok,
            style: .accent,
            handler: handler
        )
    }
}
