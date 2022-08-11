import UIKit

public protocol TextContentView: UIView { }

extension UITextField: TextContentView { }
extension UITextView: TextContentView { }

open class TextContainerView: UIView {
    // MARK: - Private properties
    private let contentView: TextContentView
    private var leftView: UIView?
    private var rightView: UIView?

    private let spacing: CGFloat

    // MARK: - Initialization
    public init(
        contentView: TextContentView,
        leftView: UIView? = nil,
        rightView: UIView? = nil,
        spacing: CGFloat = 0.0
    ) {
        self.contentView = contentView
        self.leftView = leftView
        self.rightView = rightView
        self.spacing = spacing
        super.init(frame: CGRect.zero)
        setup()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        addSubview(contentView.prepareForAutoLayout())
        
        if let leftView = leftView {
            addSubview(leftView.prepareForAutoLayout())
            leftView.leadingAnchor ~= leadingAnchor
            leftView.topAnchor ~= topAnchor
            leftView.bottomAnchor <= bottomAnchor
            contentView.leadingAnchor ~= leftView.trailingAnchor + spacing
        } else {
            contentView.leadingAnchor ~= leadingAnchor
        }
        
        contentView.topAnchor ~= topAnchor
        contentView.bottomAnchor ~= bottomAnchor

        if let rightView = rightView {
            addSubview(rightView.prepareForAutoLayout())
            rightView.leadingAnchor ~= contentView.trailingAnchor + spacing
            rightView.topAnchor ~= topAnchor
            rightView.trailingAnchor ~= trailingAnchor
            rightView.bottomAnchor <= bottomAnchor
        } else {
            contentView.trailingAnchor ~= trailingAnchor
        }
    }
}
