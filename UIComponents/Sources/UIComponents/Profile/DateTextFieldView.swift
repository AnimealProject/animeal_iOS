import UIKit
import Style

public extension DateTextFieldView {
    struct Model {
        public let description: String
        public let textFieldText: String

        public init(
            description: String,
            textFieldText: String
        ) {
            self.description = description
            self.textFieldText = textFieldText
        }
    }
}

public final class DateTextFieldView: UIView {

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
        textField.setLeftPadding()
        textField.layer.cornerRadius = 12.0
        textField.clipsToBounds = true
        textField.inputView = datePickerView
        textField.delegate = delegate
        return textField
    }()

    // MARK: - Dependencies
    private let model: DateTextFieldView.Model
    private let textFieldFactory = TextFieldFactory()
    private let datePickerView: UIView
    private weak var delegate: UITextFieldDelegate?

    // MARK: - Initialization
    public init(
        model: DateTextFieldView.Model,
        datePickerView: UIView,
        delegate: UITextFieldDelegate?
    ) {
        self.model = model
        self.datePickerView = datePickerView
        self.delegate = delegate

        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setText(_ text: String) {
        textField.text = text
    }
}

private extension DateTextFieldView {

    // MARK: - Setup
    func setup() {
        titleLabel.text = model.description
        textField.text = model.textFieldText

        let imageView = UIImageView(image: Asset.Images.calendar.image).prepareForAutoLayout()
        let imageViewContainer = UIView().prepareForAutoLayout()
        imageViewContainer.addSubview(imageView)
        imageView.topAnchor ~= imageViewContainer.topAnchor
        imageView.leadingAnchor ~= imageViewContainer.leadingAnchor
        imageView.trailingAnchor ~= imageViewContainer.trailingAnchor - 18.0
        imageView.bottomAnchor ~= imageViewContainer.bottomAnchor

        textField.setRightPaddingView(imageViewContainer)

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
        textFieldFactory.makeNameTextField()
    }
}
