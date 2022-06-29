import Foundation

final class VerificationViewModel: VerificationViewModelLifeCycle, VerificationViewInteraction, VerificationViewState {
    // MARK: - Private properties
    private lazy var timeFormatter: DateComponentsFormatter = {
         let formatter = DateComponentsFormatter()
         formatter.allowedUnits = [.minute, .second]
         formatter.unitsStyle = .positional
         formatter.zeroFormattingBehavior = []
         return formatter
     }()

    // MARK: - Dependencies
    private let model: VerificationModelProtocol


    // MARK: - State
    var onHeaderHasBeenPrepared: ((VerificationViewHeader) -> Void)?
    var onCodeHasBeenPrepared: ((VerificationViewCode, Bool) -> Void)?
    var onResendCodeHasBeenPrepared: ((VereficationViewResendCode) -> Void)?


    // MARK: - Initialization
    init(
        model: VerificationModelProtocol
    ) {
        self.model = model
        setup()
    }

    // MARK: - Life cycle
    func setup() {
        model.fetchNewCodeResponse = { [weak self] modelCode in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onCodeHasBeenPrepared?(
                    VerificationViewCode(
                        state: VerificationViewCodeState.normal,
                        items: modelCode.items.map {
                            VerificationViewCodeItem(identifier: $0.identifier, text: $0.text)
                        }
                    ),
                    true
                )
            }
        }
        model.fetchNewCodeResponseTimeLeft = { [weak self] modelTimeLeft in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onResendCodeHasBeenPrepared?(
                    VereficationViewResendCode(
                        title: "Resend code in",
                        timeLeft: self.timeFormatter.string(
                            from: TimeInterval(modelTimeLeft.time)
                        )
                    )
                )
            }
        }
    }

    func load() {
        onHeaderHasBeenPrepared?(
            VerificationViewHeader(
                title: "Enter verification code",
                subtitle: "Code was sent to: 558 49-99-69"
            )
        )
        model.fetchInitialCode()
        model.fetchNewCode()
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: VerificationViewActionEvent) {
        switch event {
        case .tapResendCode:
            model.fetchNewCode()
        case .changeCode(let viewCodeItems):
            let modelCode = VerificationModelCode(
                items: viewCodeItems.map {
                    VerificationModelCodeItem(identifier: $0.identifier, text: $0.text)
                }
            )
            guard model.isValidationNeeded(modelCode) else { return }
            let isValid = model.validateCode(modelCode)
            let state = isValid ?
                VerificationViewCodeState.normal : VerificationViewCodeState.error
            onCodeHasBeenPrepared?(
                VerificationViewCode(
                    state: state,
                    items: viewCodeItems
                ),
                false
            )
        }
    }
}
