import UIKit

public final class DateInputView: TextInputFilledDecorator<DateTextContentView> {
    public override var inputView: UIView? {
        get { contentView.inputView }
        set { contentView.inputView = newValue }
    }

    public var valueWasChanged: ((TextFieldContainable, Date) -> Void)? {
        get { contentView.valueWasChanged }
        set { contentView.valueWasChanged = newValue }
    }

    public init() {
        super.init(contentView: DateTextContentView())
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension DateTextContentView {
    struct Model: TextFieldContainerView.Model {
        public let placeholder: String?
        public let text: String?
        public let isEditable: Bool
        public let leftActions: [TextInputView.Action]
        public let rightActions: [TextInputView.Action]

        public init(
            placeholder: String?,
            text: String?,
            isEditable: Bool = true,
            leftActions: [TextInputView.Action] = [],
            rightActions: [TextInputView.Action] = []
        ) {
            self.placeholder = placeholder
            self.text = text
            self.isEditable = isEditable
            self.leftActions = leftActions
            self.rightActions = rightActions
        }
    }
}

public final class DateTextContentView: TextFieldContainerView {
    // MARK: - Constants
    private enum Constants {
        static let insets: UIEdgeInsets = .init(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        static let spacing: CGFloat = 8.0
    }

    // MARK: - Private properties
    private let textFieldLeftView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.spacing = 16.0
        return item
    }()
    private let textFieldRightView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.spacing = 16.0
        return item
    }()
    private let textFieldView = TextFieldViewFactory()
        .makeDefaultTextField()
        .prepareForAutoLayout()

    private lazy var datePickerView: UIDatePicker = {
        let item = UIDatePicker()
        item.datePickerMode = .date
        item.preferredDatePickerStyle = .wheels
        return item
    }()

    public override var inputView: UIView? {
        get { textFieldView.inputView }
        set { textFieldView.inputView = newValue }
    }

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

    public var valueWasChanged: ((TextFieldContainable, Date) -> Void)?

    // MARK: - Initialization
    public init() {
        super.init(
            textView: textFieldView,
            leftView: textFieldLeftView,
            rightView: textFieldRightView,
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
        textFieldLeftView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        textFieldRightView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        textFieldView.placeholder = model.placeholder
        textFieldView.text = model.text
        textFieldView.isUserInteractionEnabled = model.isEditable
        model.leftActions
            .map { $0.buttonView }
            .forEach(textFieldLeftView.addArrangedSubview)
        model.rightActions
            .map { $0.buttonView }
            .forEach(textFieldRightView.addArrangedSubview)
        if let text = model.text, let date = DateFormatter.default.date(from: text) {
            datePickerView.setDate(date, animated: false)
        }
    }

    // MARK: - Setup
    private func setup() {
        clipsToBounds = true
        cornerRadius(12.0)

        textFieldView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        textFieldView.inputView = datePickerView

        datePickerView.addTarget(
            self,
            action: #selector(dateWasChanged(_:)),
            for: .valueChanged
        )
    }

    // MARK: - Actions
    @objc private func dateWasChanged(_ sender: UIDatePicker) {
        valueWasChanged?(textFieldView, sender.date)
    }
}

private extension DateFormatter {
    static let `default`: DateFormatter = {
        let item = DateFormatter()
        item.dateFormat = "dd MMM, yyyy"
        return item
    }()
}
