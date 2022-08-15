// System
import UIKit

// SDK
import UIComponents
import Style

final class MainCoordinator: Coordinatable {
    // MARK: - Private properties
    private let navigator: Navigating

    private(set) lazy var rootTabBarController: TabBarController = {
        let redVC = UIViewController()
        redVC.view.backgroundColor = .red

        let yellowVC = UIViewController()
        yellowVC.view.backgroundColor = .yellow

        let orangeVC = UIViewController()
        orangeVC.view.backgroundColor = .orange

        let purpleVC = UIViewController()
        purpleVC.view.backgroundColor = .purple

        let greenVC = UIViewController()
        greenVC.view.backgroundColor = .white

        return TabBarController(items: [
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.glass.image,
                        title: L10n.TabBar.search
                    )
                ), viewController: redVC
            ),

            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.heart.image,
                        title: L10n.TabBar.favourites
                    )
                ), viewController: yellowVC
            ),
            TabBarControllerItem(
                tabBarItemView: HomeTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.home.image
                    )
                ), viewController: HomeModuleAssembler.assemble()
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.podium.image,
                        title: L10n.TabBar.leaderBoard
                    )
                ), viewController: purpleVC
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.more.image,
                        title: L10n.TabBar.more
                    )
                ), viewController: greenVC
            )
        ])
    }()

    // MARK: - Dependencies
    private let presentingWindow: UIWindow
    private let completion: (() -> Void)?

    // MARK: - Initialization
    init(
        presentingWindow: UIWindow,
        completion: (() -> Void)?
    ) {
        self.presentingWindow = presentingWindow
        self.completion = completion
        let navigationController = UINavigationController()
        self.navigator = Navigator(navigationController: navigationController)
    }

    // MARK: - Life cycle
    func start() {
        presentingWindow.rootViewController = rootTabBarController
        rootTabBarController.selectedViewController(
            index: rootTabBarController.items.firstIndex {
                $0.viewController is HomeViewController
            }
        )
        navigator.push(rootTabBarController, animated: false, completion: nil)
        presentingWindow.makeKeyAndVisible()
    }

    func stop() {
        presentingWindow.resignKey()
    }
}
