import UIKit

public final class TextTitleView: UIView {
    // MARK: - Private properties
    private lazy var titleView = UILabel()

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
}

private extension TextTitleView {
    // MARK: - Setup
    func setup() {
        addSubview(titleView.prepareForAutoLayout())
        titleView.leadingAnchor ~= leadingAnchor
        titleView.trailingAnchor ~= trailingAnchor
        titleView.topAnchor ~= topAnchor
        titleView.bottomAnchor ~= bottomAnchor

        titleView.textColor = designEngine.colors.textPrimary.uiColor
        titleView.font = designEngine.fonts.primary.bold(16).uiFont
    }
}

// MARK: - Model
public extension TextTitleView {
    struct Model {
        public let title: String

        public init(
            title: String
        ) {
            self.title = title
        }
    }
}
