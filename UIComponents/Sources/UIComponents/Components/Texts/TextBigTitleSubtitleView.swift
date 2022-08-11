import UIKit

public extension TextBigTitleSubtitleView {
    struct Model {
        public let title: String
        public let subtitle: String?

        public init(
            title: String,
            subtitle: String?
        ) {
            self.title = title
            self.subtitle = subtitle
        }
    }
}

public final class TextBigTitleSubtitleView: UIView {
    // MARK: - Private properties
    private let containerView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .vertical
        item.distribution = .fillProportionally
        item.spacing = 10.0
        return item
    }()

    private lazy var titleView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.textColor = designEngine.colors.textPrimary.uiColor
        item.font = designEngine.fonts.primary.bold(28.0).uiFont
        item.numberOfLines = 0
        return item
    }()

    private lazy var subtitleView: UILabel = {
        let item = UILabel().prepareForAutoLayout()
        item.textColor = designEngine.colors.textPrimary.uiColor
        item.font = designEngine.fonts.primary.semibold(16.0).uiFont
        item.numberOfLines = 0
        return item
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
        if let subtitle = model.subtitle {
            subtitleView.text = subtitle
            subtitleView.isHidden = false
        } else {
            subtitleView.text = nil
            subtitleView.isHidden = true
        }
    }

    // MARK: - Setup
    private func setup() {
        addSubview(containerView)
        containerView.leadingAnchor ~= leadingAnchor
        containerView.topAnchor ~= topAnchor
        containerView.trailingAnchor ~= trailingAnchor
        containerView.bottomAnchor ~= bottomAnchor

        containerView.addArrangedSubview(titleView)
        containerView.addArrangedSubview(subtitleView)

        titleView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        titleView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        subtitleView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
        subtitleView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.vertical
        )
    }
}
