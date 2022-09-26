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
    init(model: VerificationModelProtocol) {
        self.model = model
        setup()
    }

    // MARK: - Life cycle
    func setup() {
        model.requestNewCodeTimeLeft = { modelTimeLeft in
            Task { [weak self] in
                guard let self = self else { return }
                self.onResendCodeHasBeenPrepared?(
                    VereficationViewResendCode(
                        title: L10n.Verification.ResendCode.title,
                        timeLeft: self.timeFormatter.string(
                            from: TimeInterval(modelTimeLeft.time)
                        )
                    )
                )
            }
        }
    }

    func load() {
        let modelDeliveryDestination = model.fetchDestination()
        onHeaderHasBeenPrepared?(.default(modelDeliveryDestination))

        let modelCode = model.fetchCode()
        onCodeHasBeenPrepared?(
            VerificationViewCode(
                state: VerificationViewCodeState.normal,
                items: modelCode.items.map {
                    VerificationViewCodeItem(identifier: $0.identifier, text: $0.text)
                }
            ),
            true
        )
    }

    // MARK: - Interaction
    func handleActionEvent(_ event: VerificationViewActionEvent) {
        switch event {
        case .tapResendCode:
            Task { [weak self] in
                do {
                    try await self?.model.requestNewCode()
                } catch VerificationModelCodeError.codeRequestTimeLimitExceeded {
                    // ignore
                    return
                } catch {
                    // display alert
                }
            }
        case .changeCode(let viewCodeItems):
            let modelCode = VerificationModelCode(
                items: viewCodeItems.map {
                    VerificationModelCodeItem(identifier: $0.identifier, text: $0.text)
                }
            )
            Task { [weak self] in
                do {
                    try await self?.model.verifyCode(modelCode)
                    onCodeHasBeenPrepared?(
                        VerificationViewCode(
                            state: VerificationViewCodeState.normal,
                            items: viewCodeItems
                        ),
                        false
                    )
                } catch {
                    onCodeHasBeenPrepared?(
                        VerificationViewCode(
                            state: VerificationViewCodeState.error,
                            items: viewCodeItems
                        ),
                        false
                    )
                }
            }
        }
    }
}

private extension VerificationViewHeader {
    static func `default`(_ destination: VerificationModelDeliveryDestination? = nil) -> VerificationViewHeader {
        let subtitle: String
        if let destination = destination?.value {
            subtitle = "\(L10n.Verification.Subtitle.filled) \(destination)"
        } else {
            subtitle = L10n.Verification.Subtitle.empty
        }

        return VerificationViewHeader(
            title: L10n.Verification.title,
            subtitle: subtitle
        )
    }
}
