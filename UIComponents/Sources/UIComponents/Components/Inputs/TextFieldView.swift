import UIKit

public extension TextFieldView {
    struct Model {
        public let identifier: String
        public let description: String
        public let placeholderText: String?
        public let defaultText: String?
        public let isEnabled: Bool
        public let textInputKind: TextFieldKind

        public init(
            identifier: String,
            description: String,
            placeholderText: String? = nil,
            defaultText: String? = nil,
            isEnabled: Bool = true,
            textInputKind: TextFieldKind
        ) {
            self.identifier = identifier
            self.description = description
            self.placeholderText = placeholderText
            self.defaultText = defaultText
            self.isEnabled = isEnabled
            self.textInputKind = textInputKind
        }
    }
}

public final class TextFieldView: UIView, TextFieldContainable {

    // MARK: - UI properties
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = designEngine.colors.textSecondary.uiColor
        label.numberOfLines = 1
        label.font = designEngine.fonts.primary.medium(14.0).uiFont
        return label
    }()

    private lazy var textField: UITextField = {
        let textField = makeTextField()
        textField.setPadding()
        textField.layer.cornerRadius = 12.0
        textField.clipsToBounds = true
        textField.delegate = textFieldDelegate
        textField.isEnabled = model.isEnabled
        textField.isUserInteractionEnabled = model.isEnabled
        return textField
    }()

    // MARK: - Identifier
    public var identifier: String

    // MARK: - Delegate
    public var textFieldDelegate: UITextFieldDelegate?

    // MARK: - Dependencies
    private let model: TextFieldView.Model
    private let textFieldFactory = TextFieldFactory()

    // MARK: - Initialization
    public init(
        model: TextFieldView.Model,
        delegate: UITextFieldDelegate?
    ) {
        self.identifier = model.identifier
        self.model = model
        self.textFieldDelegate = delegate

        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TextFieldView {

    // MARK: - Setup
    func setup() {
        titleLabel.text = model.description
        textField.placeholder = model.placeholderText
        textField.text = model.defaultText
        titleLabel.prepareForAutoLayout().heightAnchor ~= 22.0
        textField.prepareForAutoLayout().heightAnchor ~= 56.0
        let mainStackView = UIStackView(
            arrangedSubviews: [
                titleLabel,
                textField
            ]
        )
        mainStackView.axis = .vertical
        mainStackView.spacing = 2.0

        addSubview(mainStackView.prepareForAutoLayout())
        mainStackView.topAnchor ~= topAnchor
        mainStackView.leadingAnchor ~= leadingAnchor
        mainStackView.trailingAnchor ~= trailingAnchor
        mainStackView.bottomAnchor ~= bottomAnchor
    }

    private func makeTextField() -> UITextField {
        textFieldFactory.makeTextField(for: model.textInputKind)
    }
}
