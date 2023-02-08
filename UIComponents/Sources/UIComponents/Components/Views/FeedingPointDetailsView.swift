import UIKit
import Style

public final class FeedingPointDetailsView: UIView {
    // MARK: - Private properties
    private let infoView = PlaceInfoView()
    private let imageView = UIImageView()

    public var onTap: (() -> Void)?

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
        infoView.configure(model.placeInfoViewModel)
        imageView.image = Asset.Images.heartIcon.image
        imageView.highlightedImage = Asset.Images.heartIcon.image.withTintColor(
            designEngine.colors.error
        )
        imageView.isHighlighted = model.isHighlighted
    }

    public func toggleHighlightState() {
        imageView.isHighlighted.toggle()
    }

    public func setIcon(_ icon: UIImage) {
        infoView.setIcon(icon)
    }
}

// MARK: - Setup
private extension FeedingPointDetailsView {
    func setup() {
        addSubview(infoView.prepareForAutoLayout())
        infoView.leadingAnchor ~= leadingAnchor
        infoView.topAnchor ~= topAnchor + 2
        infoView.bottomAnchor ~= bottomAnchor

        addSubview(imageView.prepareForAutoLayout())
        imageView.heightAnchor ~= 32
        imageView.widthAnchor ~= 32
        imageView.topAnchor ~= topAnchor
        imageView.trailingAnchor ~= trailingAnchor
        imageView.leadingAnchor ~= infoView.trailingAnchor
        imageView.layer.cornerRadius = 16
        imageView.contentMode = .center
        imageView.backgroundColor = designEngine.colors.backgroundPrimary
        imageView.layer.shadowColor = designEngine.colors.textSecondary.cgColor
        imageView.layer.masksToBounds = false
        imageView.layer.shadowOpacity = 0.16
        imageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        imageView.layer.shadowRadius = 6
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = TapGestureRecognizer { [weak self] _ in
            guard let self = self else { return }
            self.onTap?()
            self.imageView.isHighlighted.toggle()
        }
        imageView.addGestureRecognizer(gestureRecognizer)
    }
}

// MARK: - Model
public extension FeedingPointDetailsView {
    struct Model: Hashable {
        public let placeInfoViewModel: PlaceInfoView.Model
        public let isHighlighted: Bool

        public init(
            placeInfoViewModel: PlaceInfoView.Model,
            isHighlighted: Bool
        ) {
            self.placeInfoViewModel = placeInfoViewModel
            self.isHighlighted = isHighlighted
        }
    }
}
