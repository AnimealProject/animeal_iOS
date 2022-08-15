import UIKit

// MARK: - View
protocol VerificationViewModelOutput: AnyObject {
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

protocol VerificationViewInteraction: AnyObject {
    func handleActionEvent(_ event: VerificationViewActionEvent)
}

protocol VerificationViewState: AnyObject {
    var onHeaderHasBeenPrepared: ((VerificationViewHeader) -> Void)? { get set }
    var onCodeHasBeenPrepared: ((VerificationViewCode, Bool) -> Void)? { get set }
    var onResendCodeHasBeenPrepared: ((VereficationViewResendCode) -> Void)? { get set }
}

// MARK: - Model

// sourcery: AutoMockable
protocol VerificationModelProtocol: AnyObject {
    var fetchNewCodeResponse: ((VerificationModelCode) -> Void)? { get set }
    var fetchNewCodeResponseTimeLeft: ((VerificationModelTimeLeft) -> Void)? { get set }

    func isValidationNeeded(_ code: VerificationModelCode) -> Bool
    func validateCode(_ code: VerificationModelCode) -> Bool
    func fetchInitialCode()
    func fetchNewCode()
}

// MARK: - Assembler
protocol VerificationAssembler {
    static func assembly() -> UIViewController
}
