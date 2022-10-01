import UIKit

// MARK: - View
@MainActor
protocol VerificationViewModelOutput: ActivityDisplayable, ErrorDisplayable {
    func applyHeader(_ viewHeader: VerificationViewHeader)
    func applyCode(_ viewCode: VerificationViewCode, _ applyDifference: Bool)
    func applyResendCode(_ viewResendCode: VereficationViewResendCode)
}

// MARK: - ViewModel
typealias VerificationCombinedViewModel = VerificationViewModelLifeCycle
    & VerificationViewInteraction
    & VerificationViewState

protocol VerificationViewModelLifeCycle: AnyObject {
    func setup()
    func load()
}

@MainActor
protocol VerificationViewInteraction: AnyObject {
    func handleActionEvent(_ event: VerificationViewActionEvent)
}

@MainActor
protocol VerificationViewState: ActivityDisplayCompatible {
    var onHeaderHasBeenPrepared: ((VerificationViewHeader) -> Void)? { get set }
    var onCodeHasBeenPrepared: ((VerificationViewCode, Bool) -> Void)? { get set }
    var onResendCodeHasBeenPrepared: ((VereficationViewResendCode) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol VerificationModelProtocol: AnyObject {
    var requestNewCodeTimeLeft: ((VerificationModelTimeLeft) -> Void)? { get set }

    func fetchDestination() -> VerificationModelDeliveryDestination
    func fetchCode() -> VerificationModelCode

    func requestNewCode() async throws
    func verifyCode(_ code: VerificationModelCode) async throws
}

// MARK: - Assembler
protocol VerificationAssembler {
    static func assembly(
        deliveryDestination: VerificationModelDeliveryDestination
    ) -> UIViewController
}

// MARK: - Coordinator
protocol VerificationCoordinatable: Coordinatable {
    func moveFromVerification(to route: VerificationRoute)
}
