// System
import UIKit

// SDK
import UIComponents
import Style

// MARK: - View Item
struct SearchViewSupplementaryExpandableItem: SearchViewSupplementary {
    let viewType: SearchSupplementaryContainable.Type = SearchSupplementaryExpandableView.self
    let sizerType: SearchSupplementaryViewSizer.Type = SearchSupplementaryViewAutoSizer.self
    let viewReuseIdentifier: String = SearchSupplementaryExpandableView.reuseIdentifier

    let title: String
    let expanded: Bool

    func isEqual(to anotherItem: SearchViewSupplementary) -> Bool {
        guard let anotherItem = anotherItem as? SearchViewSupplementaryExpandableItem
        else { return false }
        return title == anotherItem.title && expanded == anotherItem.expanded
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(expanded)
    }
}

// MARK: - View
final class SearchSupplementaryExpandableView: UICollectionReusableView {
    // MARK: - UI properties
    let titleView = UILabel().prepareForAutoLayout()
    let iconView = UIImageView().prepareForAutoLayout()

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
        addSubview(titleView)
        let titleLeadingConstraint = titleView.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: 32.0
        )
        titleLeadingConstraint.priority = .init(999.0)
        titleLeadingConstraint.isActive = true
        let titleTopConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0)
        titleTopConstraint.priority = .init(999.0)
        titleTopConstraint.isActive = true
        titleView.bottomAnchor ~= bottomAnchor - 16.0

        addSubview(iconView)
        iconView.leadingAnchor ~= titleView.trailingAnchor + 16.0
        iconView.centerYAnchor ~= centerYAnchor
        iconView.trailingAnchor ~= trailingAnchor - 32.0

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(viewWasTapped(_:))
        )
        addGestureRecognizer(tapRecognizer)
    }

    @objc private func viewWasTapped(_ sender: UITapGestureRecognizer) {
        onTap?()
    }
}

// MARK: - Configuration
extension SearchSupplementaryExpandableView: SearchSupplementaryContainable {
    static var reuseIdentifier: String { String(describing: self) }

    static var kind: SearchSupplementaryViewKind { .header }

    func configure(_ item: SearchViewSupplementary) {
        guard let item = item as? SearchViewSupplementaryExpandableItem else { return }
        titleView.text = item.title
        if item.expanded {
            apply(style: .expanded)
        } else {
            apply(style: .collapsed)
        }
    }
}

// MARK: - Styles
extension Style where Component == SearchSupplementaryExpandableView {
    static var expanded: Style<SearchSupplementaryExpandableView> {
        .init { view in
            let designEngine = view.designEngine
            view.titleView.font = designEngine.fonts.primary.semibold(16.0).uiFont
            view.titleView.textColor = designEngine.colors.textPrimary.uiColor
            view.titleView.numberOfLines = 1

            view.iconView.image = Asset.Images.arrowUp.image
        }
    }

    static var collapsed: Style<SearchSupplementaryExpandableView> {
        .init { view in
            let designEngine = view.designEngine
            view.titleView.font = designEngine.fonts.primary.semibold(16.0).uiFont
            view.titleView.textColor = designEngine.colors.textPrimary.uiColor
            view.titleView.numberOfLines = 1

            view.iconView.image = Asset.Images.arrowDown.image
        }
    }
}
