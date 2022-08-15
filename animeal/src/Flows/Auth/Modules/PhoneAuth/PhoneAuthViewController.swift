// System
import UIKit

// SDK
import UIComponents

final class PhoneAuthViewController: BaseViewController, PhoneAuthViewable {
    // MARK: - Private properties
    private let headerView = TextBigTitleSubtitleView().prepareForAutoLayout()
    private let scrollView = UIScrollView().prepareForAutoLayout()
    private let contentView = UIStackView().prepareForAutoLayout()
    private var inputViews: [TextFieldContainable] = []

    // MARK: - Dependencies
    private let viewModel: PhoneAuthViewModelProtocol

    // MARK: - Initialization
    init(viewModel: PhoneAuthViewModelProtocol) {
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
    func applyHeader(_ viewHeader: PhoneAuthViewHeader) {
        headerView.configure(viewHeader.model)
    }

    func applyItems(_ viewItems: [PhoneAuthViewItem]) {
        inputViews.forEach { $0.removeFromSuperview() }
        viewItems.forEach { item in
            switch item.type {
            case .phone:
                let inputView = PhoneTextFieldView(identifier: item.identifier)
                inputView.textFieldDelegate = self
                inputView.configure(item.phoneModel)
                inputViews.append(inputView)
                contentView.addArrangedSubview(inputView)
            case .password:
                let inputView = TextFieldView(model: item.passwordModel, delegate: self)
                inputViews.append(inputView)
                contentView.addArrangedSubview(inputView)
            }
        }
    }
}

private extension PhoneAuthViewController {
    // MARK: - Setup
    func setup() {
        view.backgroundColor = designEngine.colors.primary.uiColor

        view.addSubview(scrollView)
        scrollView.leadingAnchor ~= view.leadingAnchor + 16.0
        scrollView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        scrollView.trailingAnchor ~= view.trailingAnchor - 16.0
        scrollView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor

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
    }

    // MARK: - Binding
    func bind() {
        viewModel.onHeaderHasBeenPrepared = { [weak self] viewHeader in
            self?.applyHeader(viewHeader)
        }
        viewModel.onItemsHaveBeenPrepared = { [weak self] viewItems in
            self?.applyItems(viewItems)
        }
        viewModel.load()
    }
}

extension PhoneAuthViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        viewModel.handleReturnTapped()
        return true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let text = textField.text
        guard let identifier = (textField.superview as? TextFieldContainable)?.identifier
        else { return true }

        let result = viewModel.handleTextEvent(
            PhoneAuthViewTextEvent.shouldChangeCharactersIn(
                identifier, text, range, string
            )
        )
        textField.setCursorLocation(result.caretOffset)

        guard let text = result.formattedText else { return true }
        let attributedText = NSMutableAttributedString()
        let filledTextIndex = text.index(text.startIndex, offsetBy: result.caretOffset)
        let filledText = NSAttributedString(
            string: String(text.prefix(upTo: filledTextIndex)),
            attributes: textField.activeTextAttributes
        )
        attributedText.append(filledText)
        let placeholderText = NSAttributedString(
            string: String(text.suffix(from: filledTextIndex)),
            attributes: textField.placeholderTextAttributes
        )
        attributedText.append(placeholderText)
        textField.attributedText = attributedText

        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let identifier = (textField.superview as? TextFieldContainable)?.identifier
        else { return }
        viewModel.handleTextEvent(
            PhoneAuthViewTextEvent.endEditing(identifier, textField.text)
        )
    }
}

private extension UITextField {
    var activeTextAttributes: [NSAttributedString.Key: Any]? {
        [
            .font: designEngine.fonts.primary.medium(16.0).uiFont as Any,
            .foregroundColor: designEngine.colors.textSecondary.uiColor
        ]
    }

    var placeholderTextAttributes: [NSAttributedString.Key: Any]? {
        [
            .font: designEngine.fonts.primary.medium(16.0).uiFont as Any,
            .foregroundColor: designEngine.colors.textDescriptive.uiColor
        ]
    }
}
