import SwiftUI
import UIComponents

// MARK: - GuestAlertWrapperView
public struct GuestAlertWrapperView: View {
    let onRegister: () -> Void
    let onDismiss: () -> Void

    public init(onRegister: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.onRegister = onRegister
        self.onDismiss = onDismiss
    }

    public var body: some View {
        CustomAlertView(
            viewModel: CustomAlertView.ViewModel(
                title: L10n.LoginScreen.registerOrLogin,
                message: nil,
                primaryButtonTitle: L10n.Action.register,
                secondaryButtonTitle: L10n.Action.cancel
            ) { action in
                if action == .primary {
                    onRegister()
                } else {
                    onDismiss()
                }
            }
        )
    }
}
