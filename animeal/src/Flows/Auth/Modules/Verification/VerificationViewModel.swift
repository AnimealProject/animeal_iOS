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
    private let coordinator: VerificationCoordinatable

    // MARK: - State
    var onHeaderHasBeenPrepared: ((VerificationViewHeader) -> Void)?
    var onCodeHasBeenPrepared: ((VerificationViewCode, Bool) -> Void)?
    var onResendCodeHasBeenPrepared: ((VereficationViewResendCode) -> Void)?

    // MARK: - Initialization
    init(model: VerificationModelProtocol, coordinator: VerificationCoordinatable) {
        self.model = model
        self.coordinator = coordinator
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
            handleResendNewCode(force: false)
        case .changeCode(let viewCodeItems):
            handleChangeCode(viewCodeItems: viewCodeItems)
        }
    }

    private func handleResendNewCode(force: Bool) {
        coordinator.displayActivityIndicator { [weak self] in
            do {
                try await self?.model.requestNewCode(force: force)
            } catch VerificationModelCodeError.codeRequestTimeLimitExceeded {
                return
            } catch {
                throw error
            }
        }
    }

    private func handleChangeCode(viewCodeItems: [VerificationViewCodeItem]) {
        let modelCode = VerificationModelCode(
            items: viewCodeItems.map {
                VerificationModelCodeItem(identifier: $0.identifier, text: $0.text)
            }
        )
        do {
            try model.validateCode(modelCode)
            coordinator.displayActivityIndicator { [weak self] in
                do {
                    try await self?.model.verifyCode(modelCode)
                    self?.onCodeHasBeenPrepared?(
                        VerificationViewCode(
                            state: VerificationViewCodeState.normal,
                            items: viewCodeItems
                        ),
                        false
                    )
                    self?.coordinator.moveFromVerification(to: .fillProfile)
                } catch let error as VerificationModelCodeError where error == .codeTriesCountLimitExceeded {
                    let viewAlert = ViewAlert(
                        title: error.localizedDescription,
                        actions: [
                            .cancel(),
                            .resend { [weak self] in
                                self?.handleResendNewCode(force: false)
                            }
                        ]
                    )
                    self?.coordinator.displayAlert(viewAlert)
                } catch {
                    self?.onCodeHasBeenPrepared?(
                        VerificationViewCode(
                            state: VerificationViewCodeState.error,
                            items: viewCodeItems
                        ),
                        false
                    )
                }
            }
        } catch { }
    }
}

private extension VerificationViewHeader {
    static func `default`(
        _ destination: VerificationModelDeliveryDestination? = nil
    ) -> VerificationViewHeader {
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

private extension ViewAlertAction {
    static func cancel(_ handler: @escaping () -> Void = { }) -> ViewAlertAction {
        ViewAlertAction(
            title: L10n.Verification.Alert.cancel,
            style: .inverted,
            handler: handler
        )
    }

    static func resend(_ handler: @escaping () -> Void = { }) -> ViewAlertAction {
        ViewAlertAction(
            title: L10n.Verification.Alert.resend,
            style: .accent,
            handler: handler
        )
    }
}
