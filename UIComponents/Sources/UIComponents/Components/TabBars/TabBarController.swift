import UIKit

public protocol TabBarControllerProtocol {
    var items: [TabBarControllerItem] { get }

    func setTabBarHidden(_ isHidden: Bool, animated: Bool)
    func selectedViewController(index: Int?)
}

public enum TabIdentifier: String, CaseIterable {
    case home
    case search
    case favorites
    case leaderBoard
    case more
}

public struct TabBarControllerItem {
    public let identifier: TabIdentifier
    public let tabBarItemView: TabBarItemView
    public let viewController: UIViewController

    public init(
        identifier: TabIdentifier,
        tabBarItemView: TabBarItemView,
        viewController: UIViewController
    ) {
        self.identifier = identifier
        self.tabBarItemView = tabBarItemView
        self.viewController = viewController
    }
}

public protocol TabBarControllerDelegate: AnyObject {
    func tabBarController(_ controller: TabBarController, shouldSelectTab identifier: TabIdentifier) -> Bool
}

public class TabBarController: UIViewController {
    // MARK: - Public properties
    public let items: [TabBarControllerItem]
    public let itemsByIdentifier: [TabIdentifier: TabBarControllerItem]
    public weak var delegate: TabBarControllerDelegate?

    // MARK: - Private properties
    private let contentView = UIView()
    private var selectedViewController: UIViewController?
    private var contentViewBottomAnchor: NSLayoutConstraint?
    private lazy var tabBarView: TabBarView = {
        let tabBarView = RoundedCornersTabBarView()
        tabBarView.onSelectedItemUpdate = { [weak self] in
            self?.changeSelectedViewController()
        }
        tabBarView.setItems(
            items.map { $0.tabBarItemView }
        )
        return tabBarView
    }()

    // MARK: - Initialization
    public init(items: [TabBarControllerItem], delegate: TabBarControllerDelegate) {
        self.items = items
        self.itemsByIdentifier = Dictionary(uniqueKeysWithValues: items.map { ($0.identifier, $0) })
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = designEngine.colors.backgroundPrimary

        view.addSubview(contentView)
        contentView.prepareForAutoLayout()
        contentView.leadingAnchor ~= view.leadingAnchor
        contentView.trailingAnchor ~= view.trailingAnchor
        contentView.topAnchor ~= view.topAnchor

        view.addSubview(tabBarView.prepareForAutoLayout())
        tabBarView.leadingAnchor ~= view.leadingAnchor
        tabBarView.trailingAnchor ~= view.trailingAnchor
        tabBarView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor

        contentViewBottomAnchor = contentView.bottomAnchor ~= tabBarView.topAnchor
        contentViewBottomAnchor?.isActive = true
        changeSelectedViewController()
    }
}

extension TabBarController: TabBarControllerProtocol {
    // MARK: - Public interface
    public func setTabBarHidden(_ isHidden: Bool, animated: Bool) {
        // Prevent child view controller animations.
        view.layoutIfNeeded()
        tabBarView.removeFromSuperview()
        view.addSubview(tabBarView)
        contentViewBottomAnchor?.isActive = false
        if isHidden {
            tabBarView.leadingAnchor ~= view.leadingAnchor
            tabBarView.trailingAnchor ~= view.trailingAnchor
            tabBarView.topAnchor ~= view.bottomAnchor + 20
            contentViewBottomAnchor = contentView.bottomAnchor ~= tabBarView.topAnchor - 20
        } else {
            tabBarView.leadingAnchor ~= view.leadingAnchor
            tabBarView.trailingAnchor ~= view.trailingAnchor
            tabBarView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor
            contentViewBottomAnchor = contentView.bottomAnchor ~= tabBarView.topAnchor
        }
        contentViewBottomAnchor?.isActive = true
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    public func selectedViewController(index: Int?) {
        tabBarView.setSelectedIndex(index)
    }
}

private extension TabBarController {
    // MARK: - Private interface
    func changeSelectedViewController() {
        guard let index = tabBarView.selectedItemIndex,
              let identifier = items[safe: index]?.identifier else {
            assertionFailure("Selected item index is out of bounds or identifier is nil.")
            return
        }

        guard delegate?.tabBarController(self, shouldSelectTab: identifier) == true else {
            return
        }

        let newViewController = itemsByIdentifier[identifier]?.viewController
        if selectedViewController == newViewController,
            let navigation = selectedViewController as? UINavigationController {
            // As in standard UITabBarController.
            navigation.popViewController(animated: true)
            return
        }

        if let oldViewController = selectedViewController {
            oldViewController.willMove(toParent: nil)
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParent()
        }

        selectedViewController = newViewController
        if let newViewController = newViewController {
            addChild(newViewController)
            contentView.addSubview(newViewController.view)
            newViewController.view.prepareForAutoLayout()

            newViewController.view.leadingAnchor ~= contentView.leadingAnchor
            newViewController.view.trailingAnchor ~= contentView.trailingAnchor
            newViewController.view.topAnchor ~= contentView.topAnchor
            newViewController.view.bottomAnchor ~= contentView.bottomAnchor

            newViewController.didMove(toParent: self)
        }
    }
}
