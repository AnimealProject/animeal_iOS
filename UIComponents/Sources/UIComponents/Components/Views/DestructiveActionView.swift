import UIKit

public final class DestructiveActionView: UIView {
    // MARK: - Private properties
    private let imageView = UIImageView()
    private let titleLabel = UILabel()

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
        titleLabel.text = model.title
        imageView.image = model.image
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

        addSubview(imageView.prepareForAutoLayout())
        imageView.leadingAnchor ~= leadingAnchor
        imageView.topAnchor ~= topAnchor
        imageView.bottomAnchor ~= bottomAnchor

        addSubview(titleLabel.prepareForAutoLayout())
        titleLabel.topAnchor ~= topAnchor
        titleLabel.bottomAnchor ~= bottomAnchor
        titleLabel.leadingAnchor ~= imageView.trailingAnchor + 6
        titleLabel.trailingAnchor ~= trailingAnchor
    }
}

// MARK: - Model
extension DestructiveActionView {
    public struct Model {
        public let title: String
        public let image: UIImage?

        public init(title: String, image: UIImage? = nil) {
            self.title = title
            self.image = image
        }
    }
}
