import UIKit
import Style
import UIComponents

public final class FavouriteItemCell: UITableViewCell {
    // MARK: - Private properties
    private let containerView = UIView()
    private let infoView = PlaceInfoView()
    private let favouriteImageView = UIImageView()

    public var onTap: (() -> Void)?

    // MARK: - Initialization
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FavouriteItemCell: FavouriteCell {
    public static var reuseIdentifier: String { String(describing: self) }

    // MARK: - Configuration
    public func configure(_ model: FavouriteItem) {
        guard let model = model as? FavouriteViewItem else { return }
        selectionStyle = .none
        infoView.configure(model.placeInfo)
        favouriteImageView.image = Asset.Images.heartIcon.image
        favouriteImageView.highlightedImage = Asset.Images.heartIcon.image.withTintColor(
            designEngine.colors.error
        )
        favouriteImageView.isHighlighted = model.isHighlighted
    }

    public func setIcon(_ icon: UIImage) {
        infoView.setIcon(icon)
    }
}

// MARK: - Setup
private extension FavouriteItemCell {
    func setup() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowOffset =  .zero
        layer.shadowRadius = 4
        layer.masksToBounds = false
        contentView.layer.masksToBounds = true
        contentView.cornerRadius(12)

        containerView.backgroundColor = designEngine.colors.backgroundPrimary
        containerView.border(color: designEngine.colors.backgroundSecondary /* .lightGray*/, width: 0.1)
        containerView.cornerRadius(12)

        let safeArea = safeAreaLayoutGuide

        addSubview(containerView.prepareForAutoLayout())
        containerView.leadingAnchor ~= safeArea.leadingAnchor + 30.0
        containerView.trailingAnchor ~= safeArea.trailingAnchor - 30.0
        containerView.topAnchor ~= safeArea.topAnchor + 10.0
        containerView.bottomAnchor ~= safeArea.bottomAnchor - 10.0
        
        containerView.addSubview(infoView.prepareForAutoLayout())
        infoView.leadingAnchor ~= containerView.leadingAnchor + 10.0
        infoView.topAnchor ~= containerView.topAnchor + 10.0
        infoView.bottomAnchor ~= containerView.bottomAnchor - 10.0
        
        containerView.addSubview(favouriteImageView.prepareForAutoLayout())
        favouriteImageView.heightAnchor ~= 32.0
        favouriteImageView.widthAnchor ~= 32.0
        favouriteImageView.topAnchor ~= containerView.topAnchor + 10.0
        favouriteImageView.trailingAnchor ~= containerView.trailingAnchor - 10.0
        favouriteImageView.leadingAnchor ~= infoView.trailingAnchor + 10.0
        favouriteImageView.layer.cornerRadius = 16.0
        favouriteImageView.contentMode = .center
        favouriteImageView.backgroundColor = designEngine.colors.backgroundPrimary
        favouriteImageView.layer.shadowColor = designEngine.colors.textSecondary.cgColor
        favouriteImageView.layer.masksToBounds = false
        favouriteImageView.layer.shadowOpacity = 0.16
        favouriteImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        favouriteImageView.layer.shadowRadius = 6.0
        favouriteImageView.isUserInteractionEnabled = true
    }
}

// MARK: - Model
public struct FavouriteViewItem: FavouriteItem {
    public var cellReuseIdentifier: String = FavouriteItemCell.reuseIdentifier
    public var feedingPointId: String
    public let placeInfo: PlaceInfoView.Model
    public let isHighlighted: Bool
}

public struct FavouriteMediaContent {
    public var feedingPointId: String
    public var favouriteIcon: UIImage
}
