// System
import UIKit

// SDK
import UIComponents
import Style

final class ProfileViewController: BaseViewController, ProfileViewable {
    // MARK: - Private properties
    private let headerView = TextBigTitleSubtitleView().prepareForAutoLayout()
    private let scrollView = UIScrollView().prepareForAutoLayout()
    private let contentView = UIStackView().prepareForAutoLayout()
    private let inputsContentView = UIStackView().prepareForAutoLayout()
    private let buttonsView = ButtonContainerView(axis: .horizontal).prepareForAutoLayout()

    // MARK: - Dependencies
    private let viewModel: ProfileViewModelProtocol

    // MARK: - Initialization
    init(viewModel: ProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    override func handleKeyboardNotification(keyboardData: KeyboardData) {
        super.handleKeyboardNotification(keyboardData: keyboardData)
        UIView.animate(
            withDuration: keyboardData.animationDuration,
            delay: 0.0,
            options: keyboardData.animationCurveOption
        ) {
            self.additionalSafeAreaInsets.bottom = keyboardData.keyboardRect.height
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - State
    func applyHeader(_ viewHeader: ProfileViewHeader) {
        headerView.configure(viewHeader.model)
    }

    func applyItemsSnapshot(_ viewItemsSnapshot: ProfileViewItemsSnapshot) {
        if viewItemsSnapshot.resetPreviousItems {
            createViewItems(viewItemsSnapshot.viewItems)
        } else {
            updateViewItems(viewItemsSnapshot.viewItems)
        }
    }

    func applyActions(_ viewActions: [ProfileViewAction]) {
        buttonsView.configure(viewActions.map { $0.buttonView })
        shouldShowCancelButton(viewModel.didStartEditing)
    }

    func applyConfiguration(_ viewConfiguration: ProfileViewConfiguration) {
        navigationItem.hidesBackButton = viewConfiguration.hidesBackButton
        if !viewConfiguration.hidesBackButton {
            navigationItem.hidesBackButton = true
            let backButton = UIBarButtonItem(image: UIImage(named: Asset.Images.arrowBackOffset.name), style: .plain, target: self, action: #selector(backTapped))
            navigationItem.leftBarButtonItem = backButton
        }
    }

    @objc private func backTapped() {
        viewModel.handleBackButton()
    }
    @objc private func cancelTapped() {
        viewModel.handleCancelButton()
    }
    
    func shouldShowCancelButton(_ shouldShow: Bool) {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = shouldShow ? cancelButton : nil
    }
}

private extension ProfileViewController {
    // MARK: - Setup
    func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary
        setupKeyboardHandling()

        view.addSubview(scrollView)
        scrollView.leadingAnchor ~= view.leadingAnchor + 26.0
        scrollView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        scrollView.trailingAnchor ~= view.trailingAnchor - 26.0
        scrollView.bottomAnchor ~= view.bottomAnchor
        scrollView.canCancelContentTouches = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset.bottom = 100.0

        scrollView.addSubview(contentView)
        contentView.leadingAnchor ~= scrollView.contentLayoutGuide.leadingAnchor
        contentView.topAnchor ~= scrollView.contentLayoutGuide.topAnchor
        contentView.trailingAnchor ~= scrollView.contentLayoutGuide.trailingAnchor
        contentView.bottomAnchor ~= scrollView.contentLayoutGuide.bottomAnchor

        contentView.widthAnchor ~= scrollView.frameLayoutGuide.widthAnchor
        let contentHeightConstraint = contentView.heightAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.heightAnchor
        )
        contentHeightConstraint.priority = UILayoutPriority.defaultHigh
        contentHeightConstraint.isActive = true
        contentView.axis = .vertical
        contentView.spacing = 32.0

        inputsContentView.axis = .vertical
        inputsContentView.spacing = 32.0

        contentView.addArrangedSubview(headerView)
        contentView.addArrangedSubview(inputsContentView)

        view.addSubview(buttonsView)
        buttonsView.leadingAnchor ~= view.leadingAnchor
        buttonsView.trailingAnchor ~= view.trailingAnchor
        buttonsView.bottomAnchor ~= view.bottomAnchor
        buttonsView.onTap = { [weak self] identifier in
            self?.viewModel.handleActionEvent(
                ProfileViewActionEvent.tapInside(identifier)
            )
        }
    }

    // MARK: - Binding
    func bind() {
        viewModel.onHeaderHasBeenPrepared = { [weak self] viewHeader in
            self?.applyHeader(viewHeader)
        }
        viewModel.onItemsHaveBeenPrepared = { [weak self] viewSnapshot in
            self?.applyItemsSnapshot(viewSnapshot)
        }
        viewModel.onActionsHaveBeenPrepared = { [weak self] viewActions in
            self?.applyActions(viewActions)
        }
        viewModel.onConfigurationHasBeenPrepared = { [weak self] viewConfiguration in
            self?.applyConfiguration(viewConfiguration)
        }
        viewModel.load()
    }

    // MARK: - Configuration
    func createViewItems(_ viewItems: [ProfileViewItem]) {
        inputsContentView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        viewItems.forEach { item in
            switch item.type {
            case .phone:
                let inputView = PhoneInputView()
                inputView.configure(item.phoneModel)
                inputView.codeWasTapped = { [weak self] _ in
                    self?.viewModel.handleActionEvent(
                        ProfileViewActionEvent.itemWasTapped(item.identifier)
                    )
                }
                inputView.didBeginEditing = { [weak self] textInput in
                    guard let self = self else { return }
                    let text = textInput.text
                    let result = self.viewModel.handleItemEvent(
                        .changeText(.beginEditing(item.identifier, text))
                    )
                    textInput.setCursorLocation(result.caretOffset)
                }
                inputView.shouldChangeCharacters = { [weak self] textInput, range, string in
                    guard let self = self else { return true }
                    let text = textInput.text
                    let result = self.viewModel.handleItemEvent(
                        .changeText(
                            .shouldChangeCharactersIn(item.identifier, text, range, string)
                        )
                    )
                    textInput.text = result.formattedText
                    textInput.setCursorLocation(result.caretOffset)

                    self.viewModel.handleItemEvent(
                        .changeText(.didChange(item.identifier, result.formattedText))
                    )

                    return false
                }
                inputView.didEndEditing = { [weak self] textInput in
                    self?.viewModel.handleItemEvent(
                        .changeText(.endEditing(item.identifier, textInput.text))
                    )
                }
                inputsContentView.addArrangedSubview(inputView)
            case .birthday:
                let inputView = DateInputView()
                inputView.configure(item.dateModel)
                inputsContentView.addArrangedSubview(inputView)
                inputView.valueWasChanged = { [weak self] textInput, date in
                    let result = self?.viewModel.handleItemEvent(.changeDate(item.identifier, date))
                    textInput.text = result?.formattedText
                }
                inputView.didEndEditing = { [weak self] textInput in
                    self?.viewModel.handleItemEvent(
                        .changeText(.endEditing(item.identifier, textInput.text))
                    )
                }
            default:
                let inputView = DefaultInputView()
                inputView.configure(item.model)
                inputsContentView.addArrangedSubview(inputView)
                inputView.shouldChangeCharacters = { [weak self] textInput, range, string in
                    let text = textInput.text
                        .map {
                            let start = $0.index($0.startIndex, offsetBy: 0)
                            let end =  $0.index($0.startIndex, offsetBy: range.location)
                            let index = start..<end
                            return String($0[index]) + string
                        }
                    self?.viewModel.handleItemEvent(
                        .changeText(.didChange(item.identifier, text))
                    )

                    return true
                }
                inputView.didEndEditing = { [weak self] textInput in
                    self?.viewModel.handleItemEvent(
                        .changeText(.endEditing(item.identifier, textInput.text))
                    )
                }
            }
        }
    }
    
    func updateViewItems(_ viewItems: [ProfileViewItem]) {
        let identifiedViewInputs = inputsContentView.arrangedSubviews
            .compactMap { $0 as? TextInputDecoratable }
            .reduce([String: TextInputDecoratable]()) { partialResult, input in
                var result = partialResult
                result[input.identifier] = input
                return result
            }

        viewItems.forEach { viewItem in
            switch viewItem.type {
            case .phone:
                guard let inputView = identifiedViewInputs[viewItem.identifier] as? PhoneInputView else { return }
                inputView.configure(viewItem.phoneModel)
            case .birthday:
                guard let inputView = identifiedViewInputs[viewItem.identifier] as? DateInputView else { return }
                inputView.configure(viewItem.dateModel)
            default:
                guard let inputView = identifiedViewInputs[viewItem.identifier] as? DefaultInputView else { return }
                inputView.configure(viewItem.model)
            }
        }
    }
}
