import UIKit
import Style

private enum Constants {
    static let indicatorSize: CGFloat = 8
}

public final class TitleDisclosureView: UIView {
    // MARK: Private properties
    private let title = UILabel()
    private let imageView = UIImageView()
    private let indicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.indicatorSize / 2
        view.isHidden = true
        return view
    }()
    private var model: Model?

    // MARK: Public properties
    public var onTapHandler: ((String) -> Void)?

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
        title.text = model.title
        imageView.image = Asset.Images.arrowRight.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = designEngine.colors.textPrimary
        indicatorView.backgroundColor = designEngine.colors.error
        indicatorView.isHidden = !model.hasIndicator
        self.model = model
    }

    private func setup() {
        addSubview(title.prepareForAutoLayout())
        title.leadingAnchor ~= leadingAnchor
        title.topAnchor ~= topAnchor + 10
        title.bottomAnchor ~= bottomAnchor - 10
        title.trailingAnchor ~= trailingAnchor - 12
        title.font = designEngine.fonts.primary.regular(16)
        title.textColor = designEngine.colors.textPrimary

        addSubview(imageView.prepareForAutoLayout())
        imageView.trailingAnchor ~= trailingAnchor
        imageView.centerYAnchor ~= centerYAnchor

        addSubview(indicatorView.prepareForAutoLayout())
        indicatorView.widthAnchor ~= Constants.indicatorSize
        indicatorView.heightAnchor ~= Constants.indicatorSize
        indicatorView.trailingAnchor ~= imageView.leadingAnchor - 8
        indicatorView.centerYAnchor ~= centerYAnchor

        let gestureRecognizer = LongPressGestureRecognizer { [weak self] gesture in
            guard let self = self else { return }
            let color = self.designEngine.colors.textPrimary
            if gesture.state == .began {
                self.title.textColor = color.withAlphaComponent(0.5)
                self.imageView.tintColor = color.withAlphaComponent(0.5)
            } else if gesture.state == .ended || gesture.state == .cancelled {
                self.title.textColor = color
                self.imageView.tintColor = color
                self.onTapHandler?(self.model?.identifier ?? "")
            }
        }
        addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - Model
public extension TitleDisclosureView {
    struct Model {
        public let identifier: String
        public let title: String
        public let hasIndicator: Bool

        public init(
            identifier: String,
            title: String,
            hasIndicator: Bool = false
        ) {
            self.identifier = identifier
            self.title = title
            self.hasIndicator = hasIndicator
        }
    }
}
