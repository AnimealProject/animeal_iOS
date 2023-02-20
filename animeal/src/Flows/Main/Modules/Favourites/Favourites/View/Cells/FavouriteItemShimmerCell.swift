import UIKit
import UIComponents

final class FavouriteItemShimmerCell: UITableViewCell {
    // MARK: - Private properties
    private let shimmerView = ShimmerView(animationDirection: .leftRight)
    private let containerView = UIView()
    private let infoView = UIView()
    private let favouriteIconView = UIView()

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

extension FavouriteItemShimmerCell: FavouriteCell {
    public static var reuseIdentifier: String { String(describing: self) }

    // MARK: - Configuration
    public func configure(_ model: FavouriteItem) {
        guard let model = model as? FavouriteShimmerViewItem else { return }
        selectionStyle = .none
        shimmerView.startAnimation(withScheduler: model.scheduler)
    }
}

private extension FavouriteItemShimmerCell {
    // MARK: - Setup
    func setup() {
        shimmerView.prepareForAutoLayout()
        shimmerView.backgroundColor = designEngine.colors.backgroundPrimary
        shimmerView.cornerRadius(12.0)
        shimmerView.border(
            color: designEngine.colors.backgroundSecondary,
            width: 1.0
        )
        shimmerView.shadow()
        contentView.addSubview(shimmerView)

        let leadingConstraint = shimmerView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 30.0
        )
        leadingConstraint.priority = UILayoutPriority(999)
        leadingConstraint.isActive = true

        let topConstraint = shimmerView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 6.0
        )
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true

        shimmerView.trailingAnchor ~= contentView.trailingAnchor - 30.0
        shimmerView.bottomAnchor ~= contentView.bottomAnchor - 6.0

        shimmerView.addSubview(containerView)
        containerView.leadingAnchor ~= containerView.leadingAnchor + 10.0
        containerView.topAnchor ~= containerView.topAnchor + 10.0
        containerView.trailingAnchor ~= containerView.trailingAnchor - 10.0
        containerView.bottomAnchor ~= containerView.bottomAnchor - 10.0

        shimmerView.apply(style: .lightShimmerStyle)

        setupMask()
    }

    func setupMask() {
        let masksContentView = UIView()

        let iconView = ShimmerMaskContentView().prepareForAutoLayout()
        iconView.heightAnchor ~= 82.0
        iconView.widthAnchor ~= 82.0
        iconView.cornerRadius(10.0)

        masksContentView.addSubview(iconView)
        iconView.leadingAnchor ~= masksContentView.leadingAnchor
        iconView.topAnchor ~= masksContentView.topAnchor
        iconView.bottomAnchor ~= masksContentView.bottomAnchor

        let titleView = ShimmerMaskContentView().prepareForAutoLayout()
        titleView.heightAnchor ~= 24.0

        masksContentView.addSubview(titleView)
        titleView.leadingAnchor ~= iconView.trailingAnchor + 10.0
        titleView.topAnchor ~= iconView.topAnchor

        let statusView = ShimmerMaskContentView().prepareForAutoLayout()
        statusView.heightAnchor ~= 20.0
        statusView.widthAnchor ~= 68.0

        masksContentView.addSubview(statusView)
        statusView.bottomAnchor ~= masksContentView.bottomAnchor - 8.0
        statusView.leadingAnchor ~= titleView.leadingAnchor

        let imageView = ShimmerMaskContentView().prepareForAutoLayout()
        imageView.heightAnchor ~= 32.0
        imageView.widthAnchor ~= 32.0
        imageView.cornerRadius(16.0)

        masksContentView.addSubview(imageView)
        imageView.topAnchor ~= masksContentView.topAnchor
        imageView.trailingAnchor ~= masksContentView.trailingAnchor
        imageView.leadingAnchor ~= titleView.trailingAnchor + 24.0

        shimmerView.setMask(masksContentView)
    }
}

// MARK: - Model
struct FavouriteShimmerViewItem: FavouriteItem {
    var feedingPointId = String.empty
    public var cellReuseIdentifier: String = FavouriteItemShimmerCell.reuseIdentifier
    public let scheduler: ShimmerViewScheduler
}
