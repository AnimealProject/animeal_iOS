import UIKit

public extension TextParagraphView {
    struct Model {
        public let title: String

        public init(
            title: String
        ) {
            self.title = title
        }
    }
}

public final class TextParagraphView: UIView {
    // MARK: - Private properties
    private lazy var titleView: UITextView = {
        let view = UITextView().prepareForAutoLayout()
        view.textColor = designEngine.colors.textPrimary
        view.font = designEngine.fonts.primary.light(14)
        view.backgroundColor = designEngine.colors.backgroundPrimary
        view.textAlignment = .left
        view.sizeToFit()
        view.isScrollEnabled = false
        view.isEditable = false
        return view
    }()

    // MARK: - Initialization
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        titleView.text = model.title
    }

    // MARK: - Setup
    private func setup() {
        addSubview(titleView)
        titleView.leadingAnchor ~= leadingAnchor
        titleView.trailingAnchor ~= trailingAnchor
        titleView.topAnchor ~= topAnchor
        titleView.bottomAnchor ~= bottomAnchor
    }
}
