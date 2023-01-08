// System
import UIKit

// SDK
import Style
import Kingfisher

public final class PlaceInfoView: UIView {
    // MARK: - Private properties
    private let statusView = StatusView()
    private let imageView = UIImageView()
    private let titleview = UILabel()

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
        switch model.icon {
        case .url(let url):
            imageView.kf.setImage(
                with: url,
                placeholder: Asset.Images.placeCoverPlaceholder.image,
                options: [
                    .loadDiskFileSynchronously,
                    .cacheOriginalImage,
                    .transition(.fade(0.25))
                ]
            )
        case .image(let image):
            imageView.image = image
        }

        titleview.text = model.title
        statusView.configure(model.status)
    }

    public func setIcon(_ icon: UIImage) {
        imageView.image = icon
    }
}

// MARK: - Setup
private extension PlaceInfoView {
    func setup() {
        addSubview(imageView.prepareForAutoLayout())
        imageView.leadingAnchor ~= leadingAnchor
        imageView.topAnchor ~= topAnchor
        imageView.bottomAnchor ~= bottomAnchor
        imageView.cornerRadius(10.0)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.heightAnchor ~= 82.0
        imageView.widthAnchor ~= 82.0

        addSubview(statusView.prepareForAutoLayout())
        statusView.bottomAnchor ~= bottomAnchor - 8
        statusView.leadingAnchor ~= imageView.trailingAnchor + 10

        addSubview(titleview.prepareForAutoLayout())
        titleview.leadingAnchor ~= imageView.trailingAnchor + 10.0
        titleview.trailingAnchor ~= trailingAnchor
        titleview.topAnchor ~= imageView.topAnchor
        titleview.font = designEngine.fonts.primary.medium(16.0).uiFont
        titleview.numberOfLines = 2

        addSubview(statusView.prepareForAutoLayout())
        statusView.bottomAnchor ~= bottomAnchor - 8.0
        statusView.leadingAnchor ~= imageView.trailingAnchor + 10.0
    }
}

// MARK: - Model
public extension PlaceInfoView {
    struct Model: Hashable {
        let icon: Icon
        let title: String
        let status: StatusView.Model

        public init(
            icon: Icon,
            title: String,
            status: StatusView.Model
        ) {
            self.icon = icon
            self.title = title
            self.status = status
        }
    }

    enum Icon: Hashable {
        case url(URL?)
        case image(UIImage?)
    }
}
