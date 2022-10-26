// System
import UIKit

// SDK
import UIComponents
import Style

// MARK: - View Item
struct SearchViewSupplementaryShimmerItem: SearchViewSupplementary {
    let viewType: SearchSupplementaryContainable.Type = SearchSupplementaryShimmerView.self
    let sizerType: SearchSupplementaryViewSizer.Type = SearchSupplementaryViewAutoSizer.self
    let viewReuseIdentifier: String = SearchSupplementaryShimmerView.reuseIdentifier

    let scheduler: ShimmerViewScheduler

    func isEqual(to anotherItem: SearchViewSupplementary) -> Bool {
        guard let anotherItem = anotherItem as? SearchViewSupplementaryShimmerItem
        else { return false }
        return scheduler == anotherItem.scheduler
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(scheduler)
    }
}

// MARK: - View
final class SearchSupplementaryShimmerView: UICollectionReusableView {
    // MARK: - UI properties
    private let innerView = ShimmerView(
        animationDirection: .leftRight
    ).prepareForAutoLayout()

    // MARK: - Hadler
    var onTap: (() -> Void)?

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
        addSubview(innerView)

        let leadingConstraint = innerView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: 32.0
        )
        leadingConstraint.priority = UILayoutPriority(999)
        leadingConstraint.isActive = true

        let topConstraint = innerView.topAnchor.constraint(
            equalTo: topAnchor,
            constant: 16.0
        )
        topConstraint.priority = UILayoutPriority(999)
        topConstraint.isActive = true

        innerView.trailingAnchor ~= trailingAnchor - 32.0
        innerView.bottomAnchor ~= bottomAnchor - 16.0

        innerView.apply(style: .lightShimmerStyle)
        setupMask()
    }

    private func setupMask() {
        let masksContentView = UIView()

        let titleView = ShimmerMaskContentView().prepareForAutoLayout()
        titleView.heightAnchor ~= 24.0

        masksContentView.addSubview(titleView)
        titleView.leadingAnchor ~= masksContentView.leadingAnchor
        titleView.topAnchor ~= masksContentView.topAnchor
        titleView.bottomAnchor ~= masksContentView.bottomAnchor

        let iconView = ShimmerMaskContentView().prepareForAutoLayout()
        iconView.heightAnchor ~= 10.0
        iconView.widthAnchor ~= 18.0

        masksContentView.addSubview(iconView)
        iconView.trailingAnchor ~= masksContentView.trailingAnchor
        iconView.leadingAnchor ~= titleView.trailingAnchor + 24.0
        iconView.centerYAnchor ~= masksContentView.centerYAnchor

        innerView.setMask(masksContentView)
    }
}

// MARK: - Configuration
extension SearchSupplementaryShimmerView: SearchSupplementaryContainable {
    static var reuseIdentifier: String { String(describing: self) }

    static var kind: SearchSupplementaryViewKind { .header }

    func configure(_ item: SearchViewSupplementary) {
        guard let item = item as? SearchViewSupplementaryShimmerItem else { return }
        innerView.startAnimation(withScheduler: item.scheduler)
    }
}
