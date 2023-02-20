// System
import UIKit

// SDK
import UIComponents
import Style

struct SearchPointViewItem: SearchViewItem {
    let cellReuseIdentifier: String = SearchPointCell.reuseIdentifier
    let cellType: SearchCellContainable.Type = SearchPointCell.self
    let cellSizerType: SearchCellSizer.Type = SearchCellAutoSizer.self

    let identifier: String
    let model: FeedingPointDetailsView.Model

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(model)
    }

    func isEqual(to anotherItem: SearchViewItem) -> Bool {
        guard let anotherItem = anotherItem as? SearchPointViewItem
        else { return false }
        return identifier == anotherItem.identifier && model == anotherItem.model
    }
}

final class SearchPointCell: UICollectionViewCell {
    // MARK: - UI properties
    private let innerView = FeedingPointDetailsView().prepareForAutoLayout()

    // MARK: - Handlers
    var didTapOnFavorite: (() -> Void)? {
        get { innerView.didTapOnFavorite }
        set { innerView.didTapOnFavorite = newValue }
    }

    var didTapOnContent: (() -> Void)?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        innerView.reset()
    }

    // MARK: - Setup
    private func setup() {
        let containerView = UIView().prepareForAutoLayout()
        containerView.backgroundColor = designEngine.colors.backgroundPrimary
        containerView.cornerRadius(12.0)
        containerView.border(
            color: designEngine.colors.backgroundSecondary,
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
        
        let gestureRecognizer = TapGestureRecognizer { [weak self] _ in
            guard let self = self else { return }
            self.didTapOnContent?()
        }
        innerView.addGestureRecognizer(gestureRecognizer)
    }
}

extension SearchPointCell: SearchCellContainable {
    static var reuseIdentifier: String { String(describing: self) }

    func configure(_ item: SearchViewItem) {
        guard let item = item as? SearchPointViewItem else { return }
        innerView.configure(item.model)
    }
}
