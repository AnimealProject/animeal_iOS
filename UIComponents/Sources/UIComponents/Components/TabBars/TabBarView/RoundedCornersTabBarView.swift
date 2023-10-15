import UIKit

public class RoundedCornersTabBarView: UIView {
    // MARK: - Public properties
    private(set) var selectedItemIndex: Int?
    public var onSelectedItemUpdate: (() -> Void)?
    var selectedItem: TabBarItemView? {
        guard let index = selectedItemIndex else {
            return nil
        }
        return items[safe: index]
    }

    // MARK: - Private properties
    private var items: [TabBarItemView] = []
    private var itemViews: [TabBarItemView] = []
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        return stackView
    }()

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)

        let roundedConersView = UIView().prepareForAutoLayout()
        roundedConersView.backgroundColor = designEngine.colors.backgroundPrimary
        addSubview(roundedConersView)
        roundedConersView.leadingAnchor ~= leadingAnchor
        roundedConersView.trailingAnchor ~= trailingAnchor
        roundedConersView.topAnchor ~= topAnchor - 8
        roundedConersView.heightAnchor ~= 16
        roundedConersView.layer.cornerRadius = 8

        roundedConersView.layer.shadowOffset = CGSize(width: 0, height: -6)
        roundedConersView.layer.shadowRadius = 3
        roundedConersView.layer.shadowOpacity = 0.3

        addSubview(stackView.prepareForAutoLayout())
        stackView.leadingAnchor ~= leadingAnchor + 5
        stackView.trailingAnchor ~= trailingAnchor - 5
        stackView.bottomAnchor ~= bottomAnchor - 10
        stackView.topAnchor ~= topAnchor + 8

        backgroundColor = designEngine.colors.backgroundPrimary
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateSelection()
    }
}

extension RoundedCornersTabBarView: TabBarView {
    // MARK: - Public interface
    public func setItems(_ items: [TabBarItemView]) {
        self.items = items
        selectedItemIndex = items.isEmpty ? nil : 0

        itemViews.forEach { $0.removeFromSuperview() }

        itemViews = items.enumerated().map { index, tabBarItemView in
            stackView.addArrangedSubview(tabBarItemView)
            let gestureRecognizer = TapGestureRecognizer { [weak self] _ in
                self?.setSelectedIndex(index)
                self?.onSelectedItemUpdate?()
            }
            tabBarItemView.addGestureRecognizer(gestureRecognizer)

            return tabBarItemView
        }

        UIView.performWithoutAnimation {
            updateSelection()
        }
    }

    func setSelectedIndex(_ index: Int?) {
        selectedItemIndex = index
        onSelectedItemUpdate?()
        updateSelection()
    }
}

private extension RoundedCornersTabBarView {
    // MARK: - Private interface
    private func updateSelection() {
        itemViews.enumerated().forEach { index, view in
            view.setSelected(index == selectedItemIndex)
        }
    }
}
