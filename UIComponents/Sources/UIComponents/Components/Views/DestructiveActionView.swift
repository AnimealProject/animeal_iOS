import UIKit
import Style

public final class DestructiveActionView: UIView {
    // MARK: - Private properties
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronView = UIImageView()

    // MARK: - Public properties
    public var actionHandler: (() -> Void)?

    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        let tintColor = model.imageTintColor ?? designEngine.colors.error
        titleLabel.text = model.title
        titleLabel.textColor = model.titleColor ?? designEngine.colors.error
        imageView.image = model.image
        imageView.tintColor = tintColor
        chevronView.image = Asset.Images.arrowRight.image.withRenderingMode(.alwaysTemplate)
        chevronView.tintColor = designEngine.colors.textPrimary
        accessibilityIdentifier = model.accessibilityIdentifier
    }

    // MARK: - Setup
    private func setup() {
        let gestureRecognizer = TapGestureRecognizer { [weak self] _ in
            self?.actionHandler?()
        }
        addGestureRecognizer(gestureRecognizer)

        imageView.tintColor = designEngine.colors.error
        imageView.widthAnchor ~= 16
        imageView.heightAnchor ~= 16

        titleLabel.font = designEngine.fonts.primary.light(16)
        titleLabel.textColor = designEngine.colors.error

        chevronView.image = Asset.Images.arrowRight.image.withRenderingMode(.alwaysTemplate)
        chevronView.tintColor = designEngine.colors.textPrimary

        addSubview(imageView.prepareForAutoLayout())
        imageView.leadingAnchor ~= leadingAnchor
        imageView.centerYAnchor ~= centerYAnchor

        addSubview(chevronView.prepareForAutoLayout())
        chevronView.trailingAnchor ~= trailingAnchor
        chevronView.centerYAnchor ~= centerYAnchor

        addSubview(titleLabel.prepareForAutoLayout())
        titleLabel.topAnchor ~= topAnchor
        titleLabel.bottomAnchor ~= bottomAnchor
        titleLabel.leadingAnchor ~= imageView.trailingAnchor + 6
        titleLabel.trailingAnchor <= chevronView.leadingAnchor - 12
    }
}

// MARK: - Model
extension DestructiveActionView {
    public struct Model {
        public let title: String
        public let image: UIImage?
        public let accessibilityIdentifier: String?
        public let titleColor: UIColor?
        public let imageTintColor: UIColor?

        public init(
            title: String,
            image: UIImage? = nil,
            accessibilityIdentifier: String? = nil,
            titleColor: UIColor? = nil,
            imageTintColor: UIColor? = nil,
        ) {
            self.title = title
            self.image = image
            self.accessibilityIdentifier = accessibilityIdentifier
            self.titleColor = titleColor
            self.imageTintColor = imageTintColor
        }
    }
}
