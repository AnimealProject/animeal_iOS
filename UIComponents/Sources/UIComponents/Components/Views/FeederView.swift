import UIKit

public final class FeederView: UIView {
    // MARK: - Private properties
    private let title = UILabel()
    private let subtitle = UILabel()
    private let imageView = UIImageView()

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
        title.text = model.title
        subtitle.text = model.subtitle
        imageView.image = model.icon
    }
}

private extension FeederView {
    // MARK: - Setup
    func setup() {
        addSubview(imageView.prepareForAutoLayout())
        imageView.leadingAnchor ~= leadingAnchor
        imageView.topAnchor ~= topAnchor
        imageView.bottomAnchor ~= bottomAnchor
        imageView.heightAnchor ~= 56
        imageView.widthAnchor ~= 56
        imageView.cornerRadius(28)

        addSubview(title.prepareForAutoLayout())
        title.topAnchor ~= topAnchor + 4
        title.leadingAnchor ~= imageView.trailingAnchor + 16
        title.font = designEngine.fonts.primary.medium(16).uiFont
        title.textColor = designEngine.colors.textPrimary.uiColor

        addSubview(subtitle.prepareForAutoLayout())
        subtitle.topAnchor ~= title.bottomAnchor + 8
        subtitle.leadingAnchor ~= title.leadingAnchor
        subtitle.font = designEngine.fonts.primary.light(12).uiFont
        subtitle.textColor = designEngine.colors.textPrimary.uiColor
    }
}

// MARK: - Model
public extension FeederView {
    struct Model {
        public let title: String
        public let subtitle: String
        public let icon: UIImage?

        public init(
            title: String,
            subtitle: String,
            icon: UIImage?
        ) {
            self.title = title
            self.subtitle = subtitle
            self.icon = icon
        }
    }
}
