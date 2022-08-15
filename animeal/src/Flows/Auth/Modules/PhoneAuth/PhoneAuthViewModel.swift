// System
import Foundation

// SDK
import Common

final class PhoneAuthViewModel: PhoneAuthViewModelProtocol {
    // MARK: - Private properties
    private lazy var formatter = PlaceholderTextInputFormatter(
        textPattern: "xxx xx-xx-xx"
    )

    // MARK: - Dependencies
    private let model: PhoneAuthModelProtocol
    private let coordinator: PhoneAuthCoordinatable
    private let mapper: PhoneAuthViewItemMappable

    // MARK: - State
    var onHeaderHasBeenPrepared: ((PhoneAuthViewHeader) -> Void)?
    var onItemsHaveBeenPrepared: (([PhoneAuthViewItem]) -> Void)?

    // MARK: - Initialization
    init(
        model: PhoneAuthModelProtocol,
        coordinator: PhoneAuthCoordinatable,
        mapper: PhoneAuthViewItemMappable
    ) {
        self.model = model
        self.coordinator = coordinator
        self.mapper = mapper
    }

    // MARK: - Life cycle
    func setup() {
        model.fetchItemsResponse = { [weak self] modelItems in
            guard let self = self else { return }
            let viewItems = self.mapper.mapItems(modelItems)
            self.onItemsHaveBeenPrepared?(viewItems)
        }

        model.proceedAuthenticationResponse = { [weak self] result in
            self?.processAuthenticationFeedback(result)
        }
    }

    func load() {
        let viewHeader = PhoneAuthViewHeader(
            title: L10n.Phone.title
        )
        onHeaderHasBeenPrepared?(viewHeader)

        model.fetchItems()
    }

    // MARK: - Interaction
    @discardableResult
    func handleTextEvent(_ event: PhoneAuthViewTextEvent) -> PhotoAuthViewText {
        switch event {
        case let .beginEditing(_, text):
            let offset = formatter.getCaretOffset(for: text ?? "")
            return PhotoAuthViewText(caretOffset: offset, formattedText: text)
        case let .shouldChangeCharactersIn(identifier, text, range, replacementString):
            guard let item = model.fetchItem(identifier), item.type == .phone
            else {
                let text = (text ?? "") + replacementString
                return PhotoAuthViewText(
                    caretOffset: text.count,
                    formattedText: text
                )
            }
            let result = formatter.formatInput(
                currentText: text ?? "",
                range: range,
                replacementString: replacementString
            )
            return PhotoAuthViewText(
                caretOffset: result.caretBeginOffset,
                formattedText: result.formattedText
            )
        case let .endEditing(identifier, text):
            defer {
                let unformattedText = formatter.unformat(text ?? "")
                model.updateItem(unformattedText, forIdentifier: identifier)
            }
            let offset = formatter.getCaretOffset(for: text ?? "")
            return PhotoAuthViewText(caretOffset: offset, formattedText: text)
        }
    }

    func handleReturnTapped() {
        guard model.validateItems() else { return }
        model.proceedAuthentication()
    }
}

private extension PhoneAuthViewModel {
    private func processAuthenticationFeedback(
        _ result: Result<PhoneAuthModelNextStep, Error>
    ) {
        switch result {
        case .success(let nextStep):
            switch nextStep {
            case .setNewPassword:
                coordinator.moveFromPhoneAuth(to: PhoneAuthRoute.setNewPassword)
            case .resetPassword:
                coordinator.moveFromPhoneAuth(to: PhoneAuthRoute.resetPassword)
            case .done:
                coordinator.moveFromPhoneAuth(to: PhoneAuthRoute.done)
            case .confirm:
                coordinator.moveFromPhoneAuth(to: PhoneAuthRoute.codeConfirmation)
            case .unknown:
                break
            }
        case .failure:
            break
        }
    }
}
