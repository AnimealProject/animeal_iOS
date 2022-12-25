// System
import UIKit

// SDK
import Style

public final class PhoneInputView: TextInputFilledDecorator<PhoneTextContentView> {
    public var codeWasTapped: ((TextFieldContainable) -> Void)? {
        get { contentView.codeWasTapped }
        set { contentView.codeWasTapped = newValue }
    }

    public init() {
        super.init(contentView: PhoneTextContentView())
        textView.textColor = designEngine.colors.textSecondary.uiColor
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func configureStyle(_ textFieldState: TextInputView.State) {
        contentView.backgroundColor = designEngine.colors.backgroundSecondary.uiColor
        switch textFieldState {
        case .normal:
            textView.font = designEngine.fonts.primary.medium(16.0).uiFont
            contentView.border(width: 0.0)
            descriptionView.textColor = designEngine.colors.textSecondary.uiColor
        case .error:
            textView.font = designEngine.fonts.primary.medium(16.0).uiFont
            contentView.border(color: designEngine.colors.error.uiColor, width: 1.0)
            descriptionView.textColor = designEngine.colors.error.uiColor
        }
    }
}

public extension PhoneTextContentView {
    struct Model: TextFieldContainerView.Model {
        public let icon: UIImage?
        public let prefix: String
        public let placeholder: String?
        public let text: String?
        public let isEditable: Bool

        public init(
            icon: UIImage?,
            prefix: String,
            placeholder: String?,
            text: String?,
            isEditable: Bool = true
        ) {
            self.icon = icon
            self.prefix = prefix
            self.placeholder = placeholder
            self.text = text
            self.isEditable = isEditable
        }
    }
}

public final class PhoneTextContentView: TextFieldContainerView {
    // MARK: - Constants
    private enum Constants {
        static let spacing: CGFloat = 8.0
        static let insets: UIEdgeInsets = .init(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        static let imageSideSize: CGFloat = 26.0
    }

    // MARK: - Private properties
    private let iconView = UIImageView().prepareForAutoLayout()
    private let textFieldPrefixView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.numberOfLines = 1
        item.textAlignment = .left
        return item
    }()
    private let textFieldLeftView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.alignment = .center
        item.distribution = .fillProportionally
        item.spacing = 16.0
        return item
    }()
    private let textFieldView = TextFieldViewFactory()
        .makePhoneTextField()
        .prepareForAutoLayout()

    private lazy var leftViewTapRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(leftViewWasTapped(_:))
    )

    // MARK: - Handlers
    public var shouldBeginEditing: ((TextFieldContainable) -> Bool)? {
        get { textFieldView.shouldBeginEditing }
        set { textFieldView.shouldBeginEditing = newValue }
    }

    public var didBeginEditing: ((TextFieldContainable) -> Void)? {
        get { textFieldView.didBeginEditing }
        set { textFieldView.didBeginEditing = newValue }
    }

    public var shouldEndEditing: ((TextFieldContainable) -> Bool)? {
        get { textFieldView.shouldEndEditing }
        set { textFieldView.shouldEndEditing = newValue }
    }

    public var didEndEditing: ((TextFieldContainable) -> Void)? {
        get { textFieldView.didEndEditing }
        set { textFieldView.didEndEditing = newValue }
    }

    public var shouldChangeCharacters: ((TextFieldContainable, NSRange, String) -> Bool)? {
        get { textFieldView.shouldChangeCharacters }
        set { textFieldView.shouldChangeCharacters = newValue }
    }

    public var didChange: ((TextFieldContainable) -> Void)? {
        get { textFieldView.didChange }
        set { textFieldView.didChange = newValue }
    }

    public var shouldClear: ((TextFieldContainable) -> Bool)? {
        get { textFieldView.shouldClear }
        set { textFieldView.shouldClear = newValue }
    }

    public var shouldReturn: ((TextFieldContainable) -> Bool)? {
        get { textFieldView.shouldReturn }
        set { textFieldView.shouldReturn = newValue }
    }

    public var codeWasTapped: ((TextFieldContainable) -> Void)?

    // MARK: - Initialization
    public init() {
        super.init(
            textView: textFieldView,
            leftView: textFieldLeftView,
            spacing: Constants.spacing,
            insets: Constants.insets
        )
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public override func configure(_ model: TextFieldContainerView.Model) {
        guard let model = model as? Model else { return }
        iconView.image = model.icon
        textFieldPrefixView.text = model.prefix
        textFieldView.placeholder = model.placeholder
        textFieldView.text = model.text
        textFieldView.isUserInteractionEnabled = model.isEditable
    }

    // MARK: - Setup
    private func setup() {
        clipsToBounds = true
        cornerRadius(12.0)

        textFieldPrefixView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        textFieldPrefixView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        textFieldView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        textFieldView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )

        iconView.widthAnchor ~= Constants.imageSideSize

        textFieldLeftView.addArrangedSubview(iconView)
        textFieldLeftView.addArrangedSubview(textFieldPrefixView)
        textFieldLeftView.addGestureRecognizer(leftViewTapRecognizer)

        textFieldPrefixView.font = designEngine.fonts.primary.medium(16.0).uiFont
        textFieldPrefixView.textColor = designEngine.colors.textPrimary.uiColor

        iconView.contentMode = .scaleAspectFit
    }

    // MARK: - Handlers
    @objc private func leftViewWasTapped(_ sender: UITapGestureRecognizer) {
        codeWasTapped?(textFieldView)
    }
}
