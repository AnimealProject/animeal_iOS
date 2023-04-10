// System
import Foundation

// SDK
import Common

final class ProfileViewModel: ProfileViewModelProtocol {
    // MARK: - Private properties
    private var viewItems: [ProfileViewItem]

    // MARK: - Dependencies
    private let model: ProfileModelProtocol
    private let coordinator: ProfileCoordinatable
    private let mapper: ProfileViewItemMappable
    private let configuration: ProfileViewConfiguration
    private let dateFormatter: DateFormatter

    // MARK: - State
    var onHeaderHasBeenPrepared: ((ProfileViewHeader) -> Void)?
    var onItemsHaveBeenPrepared: (([ProfileViewItem]) -> Void)?
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

        updateViewItems(animated: false) { [weak self] in
            self?.model.fetchCachedItems() ?? []
        }
        updateViewItems { [weak self] in
            try await self?.model.fetchItems() ?? []
        }
        updateViewActions()
    }

    func validate() {
        model.validateItems()
        updateViewItems(animated: false) { [weak self] in
            self?.model.fetchCachedItems() ?? []
        }
        updateViewActions()
    }

    // MARK: - Interaction
    @discardableResult
    func handleItemEvent(_ event: ProfileViewItemEvent) -> ProfileViewText {
        switch event {
        case .changeText(let textEvent):
            return handleTextEvent(textEvent)
        case let .changeDate(identifier, date):
            let text = dateFormatter.string(from: date)
            model.updateItem(text, forIdentifier: identifier)
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
                model.updateItem(text, forIdentifier: identifier)
                updateViewActions()
                return ProfileViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }
            let unformattedText = formatter.unformat(text ?? .empty)
            model.updateItem(unformattedText, forIdentifier: identifier)
            updateViewActions()
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
                model.updateItem(text, forIdentifier: identifier)
                return ProfileViewText(
                    caretOffset: text?.count ?? .zero,
                    formattedText: text
                )
            }
            let unformattedText = formatter.unformat(text ?? .empty)
            model.updateItem(unformattedText, forIdentifier: identifier)

            return ProfileViewText(
                caretOffset: text?.count ?? .zero,
                formattedText: text
            )
        }
    }

    func handleActionEvent(_ event: ProfileViewActionEvent) {
        switch event {
        case .tapInside(let identifier):
            guard let intermediateStep = model.executeAction(identifier) else { return }
            switch intermediateStep {
            case .update:
                updateViewItems(animated: false) { [weak self] in
                    self?.model.fetchCachedItems() ?? []
                }
                updateViewActions()
            case .proceed:
                guard model.validateItems() else {
                    updateViewItems(animated: false) { [weak self] in
                        self?.model.fetchCachedItems() ?? []
                    }
                    updateViewActions()
                    return
                }
                updateViewItems(animated: false) { [weak self] in
                    self?.model.fetchCachedItems() ?? []
                }
                updateViewActions()
                coordinator.displayActivityIndicator { [weak self] in
                    guard let self else { return }
                    let nextStep = try await self.model.proceedAction(identifier)
                    self.processNextStep(nextStep)
                }
            }
        case .itemWasTapped(let identifier):
            guard let requiredAction = model.fetchRequiredAction(forIdentifier: identifier) else { return }
            switch requiredAction {
            case .openPicker(let openPickerComponents):
                let completion = { [weak self] in
                    guard let self = self else { return }
                    self.model.updateItem(nil, forIdentifier: identifier)
                    self.updateViewItems(animated: false) { [weak self] in
                        self?.model.fetchCachedItems() ?? []
                    }
                    self.coordinator.move(to: .dismiss)
                }
                coordinator.move(to: .picker({ openPickerComponents.maker(completion) }))
            }
        }
    }
}

private extension ProfileViewModel {
    private func processNextStep(
        _ nextStep: ProfileModelNextStep
    ) {
        switch nextStep {
        case .done:
            coordinator.move(to: .done)
        case let .confirm(details, attribute):
            coordinator.move(to: .confirm(details, attribute))
        }
    }

    private func updateViewItems(
        animated: Bool = true,
        _ operation: @escaping () async throws -> [ProfileModelItem]
    ) {
        guard animated else {
            Task { [weak self] in
                guard let self else { return }
                let modelItems = try await operation()
                self.viewItems = self.mapper.mapItems(modelItems)
                self.onItemsHaveBeenPrepared?(self.viewItems)
            }
            return
        }
        coordinator.displayActivityIndicator { [weak self] in
            guard let self else { return }
            let modelItems = try await operation()
            self.viewItems = self.mapper.mapItems(modelItems)
            self.onItemsHaveBeenPrepared?(self.viewItems)
        }
    }

    private func updateViewActions() {
        let modelActions = model.fetchActions()
        let viewActions = modelActions.map(ProfileViewAction.init)
        onActionsHaveBeenPrepared?(viewActions)
    }
}

private extension DateFormatter {
    static let `default`: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "dd.MM.YYYY"
        return item
    }()
}
