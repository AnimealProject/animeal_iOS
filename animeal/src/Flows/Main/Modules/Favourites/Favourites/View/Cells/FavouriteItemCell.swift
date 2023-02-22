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
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        apply(style: .cell)
        containerView.apply(style: .container)
        favouriteImageView.apply(style: .favouriteImage)
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
        apply(style: .cell)
        containerView.apply(style: .container)

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
        favouriteImageView.contentMode = .center
        favouriteImageView.apply(style: .favouriteImage)
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

private extension Style where Component == UIView {
    static var container: Style<UIView> {
        .init { view in
            let design = view.designEngine
            view.backgroundColor = design.colors.backgroundPrimary
            view.border(
                color: design.colors.backgroundSecondary /* .lightGray*/,
                width: .pixel
            )
            view.cornerRadius(12)
        }
    }
}

private extension Style where Component == UIImageView {
    static var favouriteImage: Style<UIImageView> {
        .init { view in
            let design = view.designEngine
            view.backgroundColor = design.colors.backgroundPrimary
            view.cornerRadius(16.0)
            view.shadow(
                color: design.colors.textSecondary,
                opacity: 0.16,
                offset: CGSize(width: 0, height: 3),
                radius: 6
            )
        }
    }
}

private extension Style where Component == FavouriteItemCell {
    static var cell: Style<FavouriteItemCell> {
        .init { view in
            view.layer.masksToBounds = false
            view.backgroundColor = .clear
            view.contentView.backgroundColor = .clear
            view.contentView.cornerRadius(12)
            view.contentView.layer.masksToBounds = true
            view.shadow(
                color: UIColor.black,
                opacity: 0.09,
                offset: .zero,
                radius: 4
            )
        }
    }
}
