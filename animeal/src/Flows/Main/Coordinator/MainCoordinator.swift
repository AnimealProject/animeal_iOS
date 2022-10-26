// System
import UIKit

// SDK
import UIComponents
import Style

enum HomeFlowBackwardEvent {
    case event(HomeFlowBackwardAction)
}

enum HomeFlowBackwardAction {
    case shouldShowToast(String)
}

@MainActor
final class MainCoordinator: Coordinatable {
    // MARK: - Private properties
    private let navigator: Navigating
    private var childCoordinators: [Coordinatable]
    private var backwardEvents: [HomeFlowBackwardEvent] = []
    private enum Constant {
        static let homeViewIndex = 2
    }

    private(set) lazy var rootTabBarController: TabBarController = {
        let searchNavigationController = UINavigationController()
        let searchCoordinator = SearchCoordinator(
            navigator: Navigator(navigationController: searchNavigationController)
        ) { [weak self] in
            self?.stop()
        }
        searchCoordinator.start()

        let yellowVC = UIViewController()
        yellowVC.view.backgroundColor = .yellow

        let purpleVC = UIViewController()
        purpleVC.view.backgroundColor = .purple

        let moreNavigtionController = UINavigationController()
        let moreCoordinator = MoreCoordinator(
            navigator: Navigator(navigationController: moreNavigtionController)
        ) { [weak self] event in
            if let event = event {
                self?.backwardEvents.append(event)
            }
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
                ),
                viewController: searchNavigationController
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.heart.image,
                        title: L10n.TabBar.favourites
                    )
                ),
                viewController: yellowVC
            ),
            TabBarControllerItem(
                tabBarItemView: HomeTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.home.image
                    )
                ),
                viewController: homeNavigtionController
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.podium.image,
                        title: L10n.TabBar.leaderBoard
                    )
                ),
                viewController: purpleVC
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.more.image,
                        title: L10n.TabBar.more
                    )
                ),
                viewController: moreNavigtionController
            )
        ])
    }()

    // MARK: - Dependencies
    private let presentingWindow: UIWindow
    private let completion: (([HomeFlowBackwardEvent]) -> Void)?

    // MARK: - Initialization
    init(
        presentingWindow: UIWindow,
        completion: (([HomeFlowBackwardEvent]) -> Void)?
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
        completion?(backwardEvents)
    }
}
