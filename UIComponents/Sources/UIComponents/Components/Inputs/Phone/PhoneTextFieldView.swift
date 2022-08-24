import UIKit

public extension PhoneTextFieldView {
    struct Model {
        public let identifier: String
        public let title: String
        public let icon: UIImage?
        public let prefix: String
        public let placeholder: String
        public let text: String?
        public let state: TextFieldState

        public init(
            identifier: String,
            title: String,
            icon: UIImage?,
            prefix: String,
            placeholder: String,
            text: String?,
            state: TextFieldState
        ) {
            self.identifier = identifier
            self.title = title
            self.icon = icon
            self.prefix = prefix
            self.placeholder = placeholder
            self.text = text
            self.state = state
        }
    }
}

public final class PhoneTextFieldView: UIView, TextFieldContainable {
    // MARK: - Private properties
    private lazy var titleView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.font = designEngine.fonts.primary.medium(14.0).uiFont
        item.textColor = designEngine.colors.textSecondary.uiColor
        item.numberOfLines = 1
        item.textAlignment = .left
        return item
    }()

    private let iconView = UIImageView().prepareForAutoLayout()
    private lazy var textFieldPrefixView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.font = designEngine.fonts.primary.medium(16.0).uiFont
        item.textColor = designEngine.colors.textSecondary.uiColor
        item.numberOfLines = 1
        item.textAlignment = .left
        return item
    }()
    private lazy var textFieldLeftView: UIStackView = {
        let item = UIStackView(arrangedSubviews: [
            iconView, textFieldPrefixView
        ]).prepareForAutoLayout()
        item.axis = .horizontal
        item.spacing = 16.0
        return item
    }()
    private lazy var textFieldView: UITextField = textFieldFactory.makePhoneTextField()

    private lazy var textContainerView: TextContainerView = {
        let item = TextContainerView(
            contentView: textFieldView,
            leftView: textFieldLeftView,
            spacing: 16.0
        ).prepareForAutoLayout()
        return item
    }()

    private let lineView: UIView = {
        let item = UIView().prepareForAutoLayout()
        item.heightAnchor ~= 1.0
        return item
    }()

    private lazy var descriptionView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.font = designEngine.fonts.primary.medium(10.0).uiFont
        item.textColor = designEngine.colors.error.uiColor
        item.numberOfLines = 1
        item.textAlignment = .right
        return item
    }()

    // MARK: - Identifier
    public var identifier: String

    // MARK: - Dependencies
    private let textFieldFactory = TextFieldFactory()

    public weak var textFieldDelegate: UITextFieldDelegate? {
        get { textFieldView.delegate }
        set {
            textFieldView.delegate = newValue
        }
    }

    // MARK: - Initialization
    public init(identifier: String) {
        self.identifier = identifier
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        titleView.text = model.title
        iconView.image = model.icon
        textFieldPrefixView.text = model.prefix
        textFieldView.placeholder = model.placeholder
        textFieldView.text = model.text
        switch model.state {
        case .normal:
            descriptionView.text = nil
            descriptionView.isHidden = true
        case .error(let error):
            descriptionView.text = error
            descriptionView.isHidden = false
        }
        configureStyle(model.state)
    }

    private func configureStyle(_ textFieldState: TextFieldState) {
        switch textFieldState {
        case .normal:
            textFieldView.font = designEngine.fonts.primary.medium(16.0).uiFont
            textFieldView.textColor = designEngine.colors.textPrimary.uiColor
            lineView.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
            descriptionView.textColor = designEngine.colors.error.uiColor
        case .error:
            textFieldView.font = designEngine.fonts.primary.medium(16.0).uiFont
            textFieldView.textColor = designEngine.colors.textPrimary.uiColor
            lineView.backgroundColor = designEngine.colors.error.uiColor
            descriptionView.textColor = designEngine.colors.error.uiColor
        }
    }

    // MARK: - Setup
    private func setup() {
        addSubview(titleView)
        titleView.leadingAnchor ~= leadingAnchor
        titleView.topAnchor ~= topAnchor
        titleView.trailingAnchor ~= trailingAnchor
        titleView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        titleView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )

        addSubview(textContainerView)
        textContainerView.leadingAnchor ~= titleView.leadingAnchor
        textContainerView.topAnchor ~= titleView.bottomAnchor + 16.0
        textContainerView.trailingAnchor ~= titleView.trailingAnchor

        textFieldPrefixView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        textFieldPrefixView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        textFieldView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        textFieldView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )

        iconView.widthAnchor ~= 26.0

        addSubview(lineView)
        lineView.leadingAnchor ~= titleView.leadingAnchor
        lineView.topAnchor ~= textContainerView.bottomAnchor + 16.0
        lineView.trailingAnchor ~= titleView.trailingAnchor

        addSubview(descriptionView)
        descriptionView.leadingAnchor ~= titleView.leadingAnchor
        descriptionView.topAnchor ~= lineView.bottomAnchor + 2.0
        descriptionView.trailingAnchor ~= titleView.trailingAnchor
        descriptionView.bottomAnchor ~= bottomAnchor
        let descriptionHeightConstraint = descriptionView.heightAnchor.constraint(
            equalToConstant: 0.0
        )
        descriptionHeightConstraint.priority = UILayoutPriority.defaultHigh
        descriptionHeightConstraint.isActive = true

        descriptionView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        descriptionView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
    }
}
