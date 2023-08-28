import UIKit

// MARK: - View
@MainActor
protocol VerificationViewModelOutput {
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
protocol VerificationViewState: AnyObject {
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

    func requestNewCode(force: Bool) async throws
    func validateCode(_ code: VerificationModelCode) throws
    func verifyCode(_ code: VerificationModelCode) async throws
}

// MARK: - Assembler
protocol VerificationAssembler {
    static func assembly(
        deliveryDestination: VerificationModelDeliveryDestination
    ) -> UIViewController
}

// MARK: - Coordinator
protocol VerificationCoordinatable: Coordinatable, AlertCoordinatable, ActivityDisplayable {
    func moveFromVerification(to route: VerificationRoute)
}

enum ResendMethod {
    case resendCode
    case updateAttribute(String)
}
