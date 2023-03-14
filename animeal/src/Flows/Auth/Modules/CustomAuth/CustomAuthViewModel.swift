// System
import Foundation

// SDK
import Common

final class CustomAuthViewModel: CustomAuthViewModelProtocol {
    // MARK: - Private properties
    private var viewItems: [CustomAuthViewItem]
    private var viewActions: [CustomAuthViewAction]

    // MARK: - Dependencies
    private let model: CustomAuthModelProtocol
    private let coordinator: CustomAuthCoordinatable
    private let mapper: CustomAuthViewItemMappable

    // MARK: - State
    var onHeaderHasBeenPrepared: ((CustomAuthViewHeader) -> Void)?
    var onItemsHaveBeenPrepared: ((CustomAuthUpdateViewItemsSnapshot) -> Void)?
    var onActionsHaveBeenPrepared: (([CustomAuthViewAction]) -> Void)?

    // MARK: - Initialization
    init(
        model: CustomAuthModelProtocol,
        coordinator: CustomAuthCoordinatable,
        mapper: CustomAuthViewItemMappable
    ) {
        self.model = model
        self.coordinator = coordinator
        self.mapper = mapper
        self.viewItems = []
        self.viewActions = [.next()]
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        let viewHeader = CustomAuthViewHeader(
            title: L10n.Phone.title
        )
        onHeaderHasBeenPrepared?(viewHeader)

        updateViewItems()
        updateViewActions { false }
    }

    // MARK: - Interaction
    @discardableResult
    func handleTextEvent(_ event: CustomAuthViewTextEvent) -> CustomAuthViewText {
        switch event {
        case let .beginEditing(_, text):
            model.clearErrors()
            updateViewItems(resetPreviosItems: false)
            return CustomAuthViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        case let .didChange(identifier, text):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                model.updateItem(text, forIdentifier: identifier)
                updateViewActions { [weak self] in self?.model.validate() ?? false }

                return CustomAuthViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }

            let unformattedText = formatter.unformat(text ?? "")
            model.updateItem(unformattedText, forIdentifier: identifier)
            updateViewActions { [weak self] in self?.model.validate() ?? false }

            return CustomAuthViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        case let .shouldChangeCharactersIn(identifier, text, range, replacementString):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                let text = (text ?? "") + replacementString
                return CustomAuthViewText(
                    caretOffset: text.count,
                    formattedText: text
                )
            }
            let result = formatter.formatInput(
                currentText: text ?? "",
                range: range,
                replacementString: replacementString
            )
            return CustomAuthViewText(
                caretOffset: result.caretBeginOffset,
                formattedText: result.formattedText
            )
        case let .endEditing(identifier, text):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                model.updateItem(text, forIdentifier: identifier)
                return CustomAuthViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }

            let unformattedText = formatter.unformat(text ?? "")
            model.updateItem(unformattedText, forIdentifier: identifier)
            updateViewActions { [weak self] in self?.model.validate() ?? false }
            updateViewItems(resetPreviosItems: false)

            return CustomAuthViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        }
    }

    func handleActionEvent(_ event: CustomAuthViewActionEvent) {
        switch event {
        case .tapInside:
            coordinator.displayActivityIndicator { [weak self] in
                guard let self else { return }
                self.model.clearErrors()
                self.updateViewItems()
                let result = try await self.model.authenticate()
                self.processAuthenticationFeedback(result)
            }
        case .itemWasTapped(let identifier):
            guard let requiredAction = model.fetchRequiredAction(forIdentifier: identifier) else { return }
            switch requiredAction {
            case .openPicker(let openPickerComponents):
                let completion = { [weak self] in
                    guard let self = self else { return }
                    self.model.updateItem(nil, forIdentifier: identifier)
                    self.model.clearErrors()
                    self.updateViewItems()
                    self.coordinator.moveFromCustomAuth(to: .dismiss)
                }
                coordinator.moveFromCustomAuth(
                    to: .picker({ openPickerComponents.maker(completion) })
                )
            }
        }
    }
}

private extension CustomAuthViewModel {
    private func processAuthenticationFeedback(
        _ nextStep: CustomAuthModelNextStep
    ) {
        switch nextStep {
        case .setNewPassword:
            coordinator.moveFromCustomAuth(to: CustomAuthRoute.setNewPassword)
        case .resetPassword:
            coordinator.moveFromCustomAuth(to: CustomAuthRoute.resetPassword)
        case .done:
            coordinator.moveFromCustomAuth(to: CustomAuthRoute.done)
        case .confirm(let details):
            coordinator.moveFromCustomAuth(
                to: CustomAuthRoute.codeConfirmation(details)
            )
        case .unknown:
            break
        }
    }

    private func updateViewItems(resetPreviosItems: Bool = true) {
        let modelItems = model.fetchItems()
        viewItems = mapper.mapItems(modelItems)
        let viewSnapshot = CustomAuthUpdateViewItemsSnapshot(
            resetPreviousItems: resetPreviosItems,
            viewItems: viewItems
        )
        onItemsHaveBeenPrepared?(viewSnapshot)
    }

    private func updateViewActions(_ actionsAvailable: @escaping () -> Bool) {
        let isActionEnabled = actionsAvailable()
        viewActions = viewActions.map {
            var newAction = $0
            newAction.isEnabled = isActionEnabled
            return newAction
        }
        onActionsHaveBeenPrepared?(viewActions)
    }
}
