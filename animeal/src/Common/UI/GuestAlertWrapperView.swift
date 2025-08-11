import SwiftUI
import UIComponents

// MARK: - GuestAlertWrapperView
public struct GuestAlertWrapperView: View {
    @State private var showAlert = false
    let dismiss: () -> Void

    public init(dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }

    public var body: some View {
        CustomAlertView(
            viewModel: CustomAlertView.ViewModel(
                title: L10n.LoginScreen.registerOrLogin,
                message: nil,
                primaryButtonTitle: L10n.Action.register,
                secondaryButtonTitle: L10n.Action.cancel
            ) { _ in
                dismissAlert()
            },
            isPresented: showAlert
        )
        .onAppear {
            Task { @MainActor in
                showAlert = true
            }
        }
    }

    private func dismissAlert() {
        withAnimation {
            showAlert = false
        }

        Task {
            try? await Task.sleep(nanoseconds: UIComponents.defaultAnimationDuration)
            await MainActor.run { dismiss() }
        }
    }
}
