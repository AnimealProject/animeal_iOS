// System
import Foundation

// SDK
import Common

final class ProfileViewModel: ProfileViewModelProtocol {
    // MARK: - Private properties
    private var viewItems: [ProfileViewItem]
    private var modelActions: [ProfileModelAction]

    // MARK: - Dependencies
    private let model: ProfileModelProtocol
    private let coordinator: ProfileCoordinatable
    private let mapper: ProfileViewItemMappable
    private let configuration: ProfileViewConfiguration
    private let dateFormatter: DateFormatter

    // MARK: - State
    var onHeaderHasBeenPrepared: ((ProfileViewHeader) -> Void)?
    var onItemsHaveBeenPrepared: ((ProfileViewItemsSnapshot) -> Void)?
    var onActionsHaveBeenPrepared: (([ProfileViewAction]) -> Void)?
    var onConfigurationHasBeenPrepared: ((ProfileViewConfiguration) -> Void)?

    // MARK: - Initialization
    init(
        model: ProfileModelProtocol,
        coordinator: ProfileCoordinatable,
        mapper: ProfileViewItemMappable,
        configuration: ProfileViewConfiguration,
        dateFormatter: DateFormatter = .default
    ) {
        self.model = model
        self.coordinator = coordinator
        self.mapper = mapper
        self.configuration = configuration
        self.dateFormatter = dateFormatter
        self.viewItems = []
        self.modelActions = []
    }

    // MARK: - Life cycle
    func setup() { }

    func load() {
        let viewHeader = ProfileViewHeader(
            title: L10n.Profile.header,
            subtitle: L10n.Profile.subHeader
        )
        onHeaderHasBeenPrepared?(viewHeader)
        onConfigurationHasBeenPrepared?(configuration)

        updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
            try await self?.model.fetchCachedItems() ?? []
        }
        updateViewItems { [weak self] in
            await self?.updateViewActions()
            return try await self?.model.fetchItems() ?? []
        }
    }

    // MARK: - Interaction

    func handleBackButton() {
        let canSave = modelActions.first(where: {
            ($0 as? ProfileModelSaveAction)?.appearance.isEnabled == true
        }) != nil
        guard canSave else {
            coordinator.move(to: .cancel)
            return
        }

        let viewAlert = ViewAlert(
            title: L10n.Profile.DiscardEdits.dialogHeader,
            actions: [
                .no(),
                .yes { [weak self] in
                    self?.coordinator.move(to: .cancel)
                }
            ]
        )
        coordinator.displayAlert(viewAlert)
    }

    @discardableResult
    func handleItemEvent(_ event: ProfileViewItemEvent) -> ProfileViewText {
        switch event {
        case .changeText(let textEvent):
            return handleTextEvent(textEvent)
        case let .changeDate(identifier, date):
            let text = dateFormatter.string(from: date)
            Task { [weak self] in await self?.model.updateItem(text, forIdentifier: identifier) }
            return ProfileViewText(caretOffset: text.count, formattedText: text)
        }
    }

    func handleTextEvent(_ event: ProfileViewTextEvent) -> ProfileViewText {
        switch event {
        case let .beginEditing(_, text):
            return ProfileViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        case let .didChange(identifier, text):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                Task { [weak self] in
                    await self?.model.updateItem(text, forIdentifier: identifier)
                    await self?.updateViewActions()
                }
                return ProfileViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }
            let unformattedText = formatter.unformat(text ?? .empty)
            Task { [weak self] in
                await self?.model.updateItem(unformattedText, forIdentifier: identifier)
                await self?.updateViewActions()
            }
            return ProfileViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        case let .shouldChangeCharactersIn(identifier, text, range, replacementString):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                let text = (text ?? .empty) + replacementString
                return ProfileViewText(
                    caretOffset: text.count,
                    formattedText: text
                )
            }
            let result = formatter.formatInput(
                currentText: text ?? .empty,
                range: range,
                replacementString: replacementString
            )
            return ProfileViewText(
                caretOffset: result.caretBeginOffset,
                formattedText: result.formattedText
            )
        case let .endEditing(identifier, text):
            guard let formatter = viewItems.first(where: { $0.identifier == identifier })?.formatter
            else {
                Task { [weak self] in
                    await self?.model.updateItem(text, forIdentifier: identifier)
                    await self?.validateItems()
                }
                return ProfileViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }
            let unformattedText = formatter.unformat(text ?? .empty)
            Task { [weak self] in
                await self?.model.updateItem(unformattedText, forIdentifier: identifier)
                await self?.validateItems()
            }

            return ProfileViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        }
    }

    func handleActionEvent(_ event: ProfileViewActionEvent) {
        Task { [weak self] in
            guard let self else { return }
            switch event {
            case .tapInside(let identifier):
                guard let intermediateStep = try? await self.model.executeAction(identifier) else { return }
                switch intermediateStep {
                case .update:
                    self.updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
                        try await self?.model.fetchCachedItems() ?? []
                    }
                    await self.updateViewActions()
                case .proceed:
                    await self.handleProceedAction(forIdentifier: identifier)
                case .cancel(let action):
                    let viewAlert = ViewAlert(
                        title: L10n.Profile.Cancel.dialogHeader,
                        actions: [
                            .no(),
                            .yes(handler: {
                                Task { [weak self] in
                                    try? await action()
                                    self?.coordinator.move(to: .cancel)
                                }
                            })
                        ]
                    )
                    self.coordinator.displayAlert(viewAlert)
                }
            case .itemWasTapped(let identifier):
                guard let requiredAction = await self.model.fetchRequiredAction(
                    forIdentifier: identifier
                ) else { return }
                switch requiredAction {
                case .openPicker(let openPickerComponents):
                    let completion: () -> Void = {
                        Task { @MainActor [weak self] in
                            guard let self else { return }
                            await self.model.updateItem(nil, forIdentifier: identifier)
                            self.updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
                                try await self?.model.fetchCachedItems() ?? []
                            }
                            self.coordinator.move(to: .dismiss)
                        }
                    }
                    self.coordinator.move(to: .picker({ openPickerComponents.maker(completion) }))
                }
            }
        }
    }
}

private extension ProfileViewModel {
    func processNextStep(
        _ nextStep: ProfileModelNextStep,
        actionIdentifier: String
    ) {
        switch nextStep {
        case .done:
            coordinator.move(to: .done)
        case let .confirm(details, attribute):
            let completion: (() -> Void)? = { [weak self] in
                Task { [weak self] in
                    await self?.handleProceedAction(forIdentifier: actionIdentifier)
                }
            }
            coordinator.move(to: .confirm(details, attribute, completion))
        }
    }

    func handleProceedAction(forIdentifier identifier: String) async {
        guard await model.validateItems() else {
            updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
                await self?.updateViewActions()
                return try await self?.model.fetchCachedItems() ?? []
            }
            return
        }
        updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
            await self?.updateViewActions()
            return try await self?.model.fetchCachedItems() ?? []
        }
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            let nextStep = try await self.model.proceedAction(identifier)
            self.processNextStep(nextStep, actionIdentifier: identifier)
        }
    }

    func validateItems() async {
        await model.validateItems()
        updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
            try await self?.model.fetchCachedItems() ?? []
        }
        await updateViewActions()
    }

    func updateViewItems(
        animated: Bool = true,
        resetPreviousItems: Bool = true,
        _ operation: @escaping () async throws -> [ProfileModelItem]
    ) {
        guard animated else {
            Task { [weak self] in
                guard let self else { return }
                let modelItems = try await operation()
                self.viewItems = self.mapper.mapItems(modelItems)
                let snapshot = ProfileViewItemsSnapshot(
                    resetPreviousItems: resetPreviousItems,
                    viewItems: self.viewItems
                )
                self.onItemsHaveBeenPrepared?(snapshot)
            }
            return
        }
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            let modelItems = try await operation()
            self.viewItems = self.mapper.mapItems(modelItems)
            let snapshot = ProfileViewItemsSnapshot(
                resetPreviousItems: resetPreviousItems,
                viewItems: self.viewItems
            )
            self.onItemsHaveBeenPrepared?(snapshot)
        }
    }

    func updateViewActions() async {
        modelActions = await model.fetchActions()
        let viewActions = modelActions.map(ProfileViewAction.init)
        onActionsHaveBeenPrepared?(viewActions)
    }
}

private extension DateFormatter {
    static let `default`: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "dd MMM, yyyy"
        return item
    }()
}
