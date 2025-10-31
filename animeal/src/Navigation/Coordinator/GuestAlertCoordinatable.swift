import UIKit
import SwiftUI
import UIComponents

protocol GuestAlertCoordinatable: AnyObject {
    @MainActor
    func presentGuestAlert(
        onRegister: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    )
}

extension GuestAlertCoordinatable where Self: Coordinatable {
    @MainActor
    func presentGuestAlert(
        onRegister: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        let alertVC = UIHostingController(
            rootView: GuestAlertWrapperView(
                onRegister: onRegister,
                onDismiss: onDismiss
            )
        )
        alertVC.view.backgroundColor = .clear
        alertVC.modalPresentationStyle = .overFullScreen

        navigator.present(alertVC, animated: false, completion: nil)
    }

    @MainActor
    func dismissGuestAlert(animated: Bool = true, completion: (() -> Void)? = nil) {
        navigator.topViewController?.dismiss(animated: animated, completion: completion)
    }
}
