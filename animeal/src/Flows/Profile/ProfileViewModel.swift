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
        guard let saveAction = saveAction else {
            // User didn't start to edit. Safe to go back
            coordinator.move(to: .cancel)
            return
        }
        guard saveAction.appearance.isEnabled else {
            // User started to edit i.e. activated the edit mode but did not do any changes yet.
            // Exit from editing mode and stay on the same screen.
            coordinator.move(to: .cancel)
            return
        }
        // User has changes that can be saved alert him for changes.
        let viewAlert = ViewAlert(
            title: L10n.Profile.DiscardEdits.dialogHeader,
            actions: [
                .no(),
                .yes { [weak self] in
                    self?.discardChanges()
                }
            ]
        )
        coordinator.displayAlert(viewAlert)
    }

    func handleCancelButton() {
        discardChanges()
    }

    var didStartEditing: Bool {
        // If there is no save action user didn't started to edit yet.
        saveAction != nil
    }

    /// Discards current set of changes and updates the profile view to the intial state.
    func discardChanges() {
        updateViewItems(animated: false, resetPreviousItems: false) { [weak self] in
            guard let self = self else {
                return try await self?.model.fetchCachedItems() ?? []
            }
            modelActions = try await model.discardAction()
            let viewActions = modelActions.map(ProfileViewAction.init)
            onActionsHaveBeenPrepared?(viewActions)
            return try await model.fetchCachedItems()
        }
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
                                    do {
                                        try await action()
                                        self?.coordinator.move(to: .cancel)
                                    } catch {
                                        // cancelled, stay as is
                                    }
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
    func processNextStep(_ nextStep: ProfileModelNextStep, actionIdentifier: String) {
        if case let .confirm(details, attribute, resendMethod) = nextStep {
            let completion: (() -> Void)? = { [weak self] in
                Task { [weak self] in
                    await self?.handleProceedAction(forIdentifier: actionIdentifier)
                }
            }
            coordinator.move(to: .confirm(details, attribute, resendMethod, completion))
        } else if case .done = nextStep, modelActions.count > 1 {
            // As per EPMEDU-2899 need to keep the user on profile screen post update.
            // Since this same screen is resused on registration need to redirect the user to home screen.
            // TODO: make a way to understand the user is creating an account vs user is updating profile.
            // for now simple work aorund is to check how any actions are there in the screen.
            // If there are 2 actions then registration. 1 actions then profile update.
            coordinator.move(to: .done)
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

// MARK: - Check profile screen modes
private extension ProfileViewModel {
    /// checks the action list and retruns the save action if available
    var saveAction: ProfileModelSaveAction? {
        modelActions.compactMap { $0 as? ProfileModelSaveAction }.first
    }

    /// checks the action list and retruns the edit action if available
    var editAction: ProfileModelEditAction? {
        modelActions.compactMap { $0 as? ProfileModelEditAction }.first
    }
}
