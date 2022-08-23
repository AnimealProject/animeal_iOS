import UIKit
import Style

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
        imageView.image = model.icon
        titleview.text = model.title
        statusView.configure(model.status)
    }
}

// MARK: - Setup
private extension PlaceInfoView {
    func setup() {
        addSubview(imageView.prepareForAutoLayout())
        imageView.leadingAnchor ~= leadingAnchor
        imageView.topAnchor ~= topAnchor
        imageView.bottomAnchor ~= bottomAnchor
        imageView.layer.cornerRadius = 10

        addSubview(statusView.prepareForAutoLayout())
        statusView.bottomAnchor ~= bottomAnchor - 8
        statusView.leadingAnchor ~= imageView.trailingAnchor + 10

        addSubview(titleview.prepareForAutoLayout())
        titleview.leadingAnchor ~= imageView.trailingAnchor + 10
        titleview.trailingAnchor ~= trailingAnchor
        titleview.topAnchor ~= imageView.topAnchor + 2
        titleview.bottomAnchor ~= statusView.topAnchor - 6
        titleview.font = designEngine.fonts.primary.bold(16).uiFont
        titleview.numberOfLines = 2
    }
}

// MARK: - Model
public extension PlaceInfoView {
    struct Model {
        let icon: UIImage?
        let title: String
        let status: StatusModel

        public init(
            icon: UIImage,
            title: String,
            status: StatusModel
        ) {
            self.icon = icon
            self.title = title
            self.status = status
        }
    }
}
