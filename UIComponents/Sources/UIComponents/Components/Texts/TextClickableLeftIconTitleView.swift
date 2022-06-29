import UIKit
import Style

public extension TextClickableLeftIconTitleView {
    struct Model {
        public let icon: UIImage?
        public let title: String
        public let subtitle: String?

        public init(
            icon: UIImage?,
            title: String,
            subtitle: String?
        ) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
        }
    }
}

public final class TextClickableLeftIconTitleView: UIView {
    // MARK: - Private properties
    private let containerView: UIStackView = {
        let item = UIStackView().prepareForAutoLayout()
        item.axis = .horizontal
        item.alignment = .center
        item.spacing = 16.0
        return item
    }()

    private lazy var titleView: UIButton = {
        let item = UIButton()
        item.setTitleColor(
            designEngine.colors.textSecondary.uiColor,
            for: UIControl.State.normal
        )
        item.setTitleColor(
            designEngine.colors.textDescriptive.uiColor,
            for: UIControl.State.highlighted
        )
        item.titleLabel?.font =
            designEngine.fonts.primary.semibold(14.0).uiFont
        return item
    }()

    private lazy var subtitleView: UILabel = {
        let item = UILabel()
        item.textColor = designEngine.colors.textSecondary.uiColor
        item.font = designEngine.fonts.primary.medium(14.0).uiFont
        item.textAlignment = .left
        return item
    }()

    // MARK: - Actions
    public var onClick: (() -> Void)?

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
        titleView.setTitle(model.title, for: UIControl.State.normal)

        if let icon = model.icon {
            titleView.setImage(
                icon,
                for: UIControl.State.normal
            )
        } else {
            titleView.setImage(nil, for: UIControl.State.normal)
        }

        if let subtitle = model.subtitle, !subtitle.isEmpty {
            subtitleView.text = subtitle
            subtitleView.isHidden = false
        } else {
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
        titleView.setContentCompressionResistancePriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )
        titleView.setContentHuggingPriority(
            UILayoutPriority.required,
            for: NSLayoutConstraint.Axis.horizontal
        )

        titleView.contentEdgeInsets.left = 8.0
        titleView.titleEdgeInsets.right = -8.0

        titleView.addTarget(
            self,
            action: #selector(titleViewWasTapped(_:)),
            for: UIControl.Event.touchUpInside
        )
    }

    // MARK: - Handlers
    @objc private func titleViewWasTapped(_ sender: Any) {
        onClick?()
    }
}
