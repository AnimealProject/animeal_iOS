// System
import UIKit

// SDK
import UIComponents
import Style

final class MainCoordinator: Coordinatable {
    // MARK: - Private properties
    private let navigator: Navigating
    private var childCoordinators: [Coordinatable]
    private enum Constant {
        static let homeViewIndex = 2
    }

    private(set) lazy var rootTabBarController: TabBarController = {
        let redVC = UIViewController()
        redVC.view.backgroundColor = .red

        let yellowVC = UIViewController()
        yellowVC.view.backgroundColor = .yellow

        let purpleVC = UIViewController()
        purpleVC.view.backgroundColor = .purple

        let moreNavigtionController = UINavigationController()
        let moreCoordinator = MoreCoordinator(
            navigator: Navigator(navigationController: moreNavigtionController)
        ) { [weak self] in
            self?.stop()
        }
        moreCoordinator.start()

        let homeNavigtionController = UINavigationController()
        let homeCoordinator = HomeCoordinator(
            navigator: Navigator(navigationController: homeNavigtionController)
        ) { [weak self] in
            self?.stop()
        }
        homeCoordinator.start()

        childCoordinators = [moreCoordinator, homeCoordinator]
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
                ), viewController: homeNavigtionController
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
                ), viewController: moreNavigtionController
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
        self.childCoordinators = []
    }

    // MARK: - Life cycle
    func start() {
        presentingWindow.rootViewController = rootTabBarController
        rootTabBarController.selectedViewController(index: Constant.homeViewIndex)
        navigator.push(rootTabBarController, animated: false, completion: nil)
        presentingWindow.makeKeyAndVisible()
    }

    func stop() {
        childCoordinators.removeAll()
        completion?()
    }
}
