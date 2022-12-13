// System
import UIKit

// SDK
import UIComponents
import Style

struct SearchPointShimmerViewItem: SearchViewItem {
    let cellReuseIdentifier: String = SearchPointShimmerCell.reuseIdentifier
    let cellType: SearchCellContainable.Type = SearchPointShimmerCell.self
    let cellSizerType: SearchCellSizer.Type = SearchCellAutoSizer.self

    let identifier: String
    let scheduler: ShimmerViewScheduler

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(scheduler)
    }

    func isEqual(to anotherItem: SearchViewItem) -> Bool {
        guard let anotherItem = anotherItem as? SearchPointShimmerViewItem
        else { return false }
        return identifier == anotherItem.identifier && scheduler == anotherItem.scheduler
    }
}

final class SearchPointShimmerCell: UICollectionViewCell {
    // MARK: - UI properties
    private let innerView = ShimmerView(
        animationDirection: .leftRight
    ).prepareForAutoLayout()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setup() {
        let containerView = UIView().prepareForAutoLayout()
        containerView.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        containerView.cornerRadius(12.0)
        containerView.border(
            color: designEngine.colors.backgroundSecondary.uiColor,
            width: 1.0
        )
        containerView.shadow()
        contentView.addSubview(containerView)

        let leadingConstraint = containerView.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: 30.0
        )
        leadingConstraint.priority = UILayoutPriority(999)
        leadingConstraint.isActive = true

        let topConstraint = containerView.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: 6.0
        )
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true

        containerView.trailingAnchor ~= contentView.trailingAnchor - 30.0
        containerView.bottomAnchor ~= contentView.bottomAnchor - 6.0

        containerView.addSubview(innerView)
        innerView.leadingAnchor ~= containerView.leadingAnchor + 10.0
        innerView.topAnchor ~= containerView.topAnchor + 10.0
        innerView.trailingAnchor ~= containerView.trailingAnchor - 10.0
        innerView.bottomAnchor ~= containerView.bottomAnchor - 10.0

        innerView.apply(style: .lightShimmerStyle)

        setupMask()
    }

    private func setupMask() {
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

        innerView.setMask(masksContentView)
    }
}

extension SearchPointShimmerCell: SearchCellContainable {
    static var reuseIdentifier: String { String(describing: self) }

    func configure(_ item: SearchViewItem) {
        guard let item = item as? SearchPointShimmerViewItem else { return }
        innerView.startAnimation(withScheduler: item.scheduler)
    }
}
