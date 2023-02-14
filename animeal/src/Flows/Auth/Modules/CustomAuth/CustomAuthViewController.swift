// System
import UIKit

// SDK
import UIComponents

final class CustomAuthViewController: BaseViewController, CustomAuthViewable {
    // MARK: - Private properties
    private let headerView = TextBigTitleSubtitleView().prepareForAutoLayout()
    private let scrollView = UIScrollView().prepareForAutoLayout()
    private let contentView = UIStackView().prepareForAutoLayout()
    private var inputViews: [TextInputDecoratable] = []
    private let buttonsView = ButtonContainerView().prepareForAutoLayout()

    // MARK: - Dependencies
    private let viewModel: CustomAuthViewModelProtocol

    // MARK: - Initialization
    init(viewModel: CustomAuthViewModelProtocol) {
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
    func applyHeader(_ viewHeader: CustomAuthViewHeader) {
        headerView.configure(viewHeader.model)
    }

    func applyItems(_ viewItems: [CustomAuthViewItem]) {
        inputViews.forEach {
            $0.removeFromSuperview()
            contentView.removeArrangedSubview($0)
        }
        viewItems.forEach { item in
            switch item.type {
            case .phone:
                let inputView = PhoneInputView()
                inputView.configure(item.phoneModel)
                inputView.codeWasTapped = { [weak self] _ in
                    self?.view.endEditing(true)
                    self?.viewModel.handleActionEvent(
                        CustomAuthViewActionEvent.itemWasTapped(item.identifier)
                    )
                }
                inputView.didBeginEditing = { [weak self] textInput in
                    guard let self = self else { return }
                    let text = textInput.text
                    let result = self.viewModel.handleTextEvent(
                        CustomAuthViewTextEvent.beginEditing(item.identifier, text)
                    )
                    textInput.setCursorLocation(result.caretOffset)
                }
                inputView.shouldChangeCharacters = { [weak self] textInput, range, string in
                    guard let self = self else { return true }
                    let text = textInput.text
                    let result = self.viewModel.handleTextEvent(
                        CustomAuthViewTextEvent.shouldChangeCharactersIn(
                            item.identifier, text, range, string
                        )
                    )
                    textInput.setCursorLocation(result.caretOffset)

                    guard let text = result.formattedText else { return true }
                    let attributedText = NSMutableAttributedString()
                    let filledTextIndex = text.index(text.startIndex, offsetBy: result.caretOffset)
                    let filledText = NSAttributedString(
                        string: String(text.prefix(upTo: filledTextIndex)),
                        attributes: textInput.activeTextAttributes
                    )
                    attributedText.append(filledText)
                    let placeholderText = NSAttributedString(
                        string: String(text.suffix(from: filledTextIndex)),
                        attributes: textInput.placeholderTextAttributes
                    )
                    attributedText.append(placeholderText)
                    textInput.attributedText = attributedText
                    self.viewModel.handleTextEvent(
                        CustomAuthViewTextEvent.didChange(item.identifier, text)
                    )

                    return false
                }
                inputView.didEndEditing = { [weak self] textInput in
                    guard let result = self?.viewModel.handleTextEvent(
                        CustomAuthViewTextEvent.endEditing(item.identifier, textInput.text)
                    )
                    else { return }

                    guard let text = result.formattedText else { return }
                    let attributedText = NSMutableAttributedString()
                    let filledTextIndex = text.index(text.startIndex, offsetBy: result.caretOffset)
                    let filledText = NSAttributedString(
                        string: String(text.prefix(upTo: filledTextIndex)),
                        attributes: textInput.activeTextAttributes
                    )
                    attributedText.append(filledText)
                    let placeholderText = NSAttributedString(
                        string: String(text.suffix(from: filledTextIndex)),
                        attributes: textInput.placeholderTextAttributes
                    )
                    attributedText.append(placeholderText)
                    textInput.attributedText = attributedText
                }
                inputViews.append(inputView)
                contentView.addArrangedSubview(inputView)
            case .password:
                let inputView = DefaultInputView()
                inputView.configure(item.model)
                inputViews.append(inputView)
                contentView.addArrangedSubview(inputView)
            }
        }
    }

    func applyActions(_ actions: [CustomAuthViewAction]) {
        buttonsView.configure(actions.map { $0.buttonView })
    }
}

private extension CustomAuthViewController {
    // MARK: - Setup
    func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary
        setupKeyboardHandling()

        view.addSubview(scrollView)
        scrollView.leadingAnchor ~= view.leadingAnchor + 26.0
        scrollView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        scrollView.trailingAnchor ~= view.trailingAnchor - 26.0
        scrollView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor
        scrollView.canCancelContentTouches = false

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
        contentView.spacing = 58.0

        contentView.addArrangedSubview(headerView)

        view.addSubview(buttonsView)
        buttonsView.leadingAnchor ~= view.leadingAnchor
        buttonsView.trailingAnchor ~= view.trailingAnchor
        buttonsView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor
        buttonsView.onTap = { [weak self] identifier in
            self?.viewModel.handleActionEvent(
                CustomAuthViewActionEvent.tapInside(identifier)
            )
        }
    }

    // MARK: - Binding
    func bind() {
        viewModel.onHeaderHasBeenPrepared = { [weak self] viewHeader in
            self?.applyHeader(viewHeader)
        }
        viewModel.onItemsHaveBeenPrepared = { [weak self] viewItems in
            self?.applyItems(viewItems)
        }
        viewModel.onActionsHaveBeenPrepared = { [weak self] viewActions in
            self?.applyActions(viewActions)
        }

        viewModel.load()
    }
}

private extension TextFieldContainable {
    var activeTextAttributes: [NSAttributedString.Key: Any]? {
        [
            .font: designEngine.fonts.primary.medium(16.0) as Any,
            .foregroundColor: designEngine.colors.textPrimary
        ]
    }

    var placeholderTextAttributes: [NSAttributedString.Key: Any]? {
        [
            .font: designEngine.fonts.primary.medium(16.0) as Any,
            .foregroundColor: designEngine.colors.textSecondary
        ]
    }
}
