import UIKit

public protocol TextFieldContainerViewModel {
    var text: String? { get }
    var placeholder: String? { get }
}

open class TextFieldContainerView: UIView {
    // MARK: - Model
    public typealias Model = TextFieldContainerViewModel

    // MARK: - Private properties
    public let textView: TextFieldContainable
    public var leftView: UIView?
    public var rightView: UIView?

    private let spacing: CGFloat
    private let insets: UIEdgeInsets

    // MARK: - Initialization
    public init(
        textView: TextFieldContainable,
        leftView: UIView? = nil,
        rightView: UIView? = nil,
        spacing: CGFloat = 0.0,
        insets: UIEdgeInsets = .zero
    ) {
        self.textView = textView
        self.leftView = leftView
        self.rightView = rightView
        self.spacing = spacing
        self.insets = insets
        super.init(frame: CGRect.zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    open func configure(_ model: Model) { }

    // MARK: - Setup
    private func setup() {
        addSubview(textView.prepareForAutoLayout())

        if let leftView = leftView {
            addSubview(leftView.prepareForAutoLayout())
            leftView.leadingAnchor ~= leadingAnchor + insets.left
            leftView.topAnchor ~= topAnchor + insets.top
            leftView.bottomAnchor ~= bottomAnchor - insets.bottom
            textView.leadingAnchor ~= leftView.trailingAnchor + spacing
            leftView.setContentCompressionResistancePriority(.required, for: .horizontal)
            let widthConstraint = leftView.widthAnchor.constraint(equalToConstant: 0.0)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
        } else {
            textView.leadingAnchor ~= leadingAnchor + insets.left
        }

        textView.topAnchor ~= topAnchor + insets.top
        textView.bottomAnchor ~= bottomAnchor - insets.bottom

        if let rightView = rightView {
            addSubview(rightView.prepareForAutoLayout())
            rightView.leadingAnchor ~= textView.trailingAnchor + spacing
            rightView.topAnchor ~= topAnchor + insets.top
            rightView.trailingAnchor ~= trailingAnchor - insets.right
            rightView.bottomAnchor ~= bottomAnchor - insets.bottom
            rightView.setContentCompressionResistancePriority(.required, for: .horizontal)
            let widthConstraint = rightView.widthAnchor.constraint(equalToConstant: 0.0)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
        } else {
            textView.trailingAnchor ~= trailingAnchor - insets.right
        }
    }
}
