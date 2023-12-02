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

enum MainFlowSwitchAction {
    case shouldSwitchToMap(pointIdentifier: String)
    case shouldSwitchToFeeding(feedDetails: FeedingPointFeedDetails)
}

@MainActor
final class MainCoordinator: Coordinatable {
    // MARK: - Private properties
    private let _navigator: Navigating
    private var childCoordinators: [Coordinatable]
    private var backwardEvents: [HomeFlowBackwardEvent] = []

    private var homeCoordinator: (HomeCoordinatable & HomeCoordinatorEventHandlerProtocol)? {
        let coordinator = childCoordinators.first { $0 is HomeCoordinatable && $0 is HomeCoordinatorEventHandlerProtocol }
        return coordinator as? (HomeCoordinatable & HomeCoordinatorEventHandlerProtocol)
    }

    private(set) lazy var rootTabBarController: TabBarController = {
        let searchNavigationController = UINavigationController()
        let searchCoordinator = SearchCoordinator(
            navigator: Navigator(navigationController: searchNavigationController),
            switchFlowAction: { [weak self] in self?.handleSwitchFlowAction($0) },
            completion: { [weak self] in self?.stop() }
        )
        searchCoordinator.start()

        let leaderboardNavigationController = UINavigationController()
        let leaderboardCoordinator = LeaderboardCoordinator(
            navigator: Navigator(navigationController: leaderboardNavigationController),
            completion: { [weak self] event in
                if let event = event {
                    self?.backwardEvents.append(event)
                }
                self?.stop()
            }
            )
        leaderboardCoordinator.start()

        let favouritesNavigationController = UINavigationController()
        let favouritesCoordinator = FavouritesCoordinator(
            navigator: Navigator(navigationController: favouritesNavigationController),
            switchFlowAction: { [weak self] in self?.handleSwitchFlowAction($0) },
            completion: { [weak self] event in
                if let event = event {
                    self?.backwardEvents.append(event)
                }
                self?.stop()
            }
            )
        favouritesCoordinator.start()

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

        childCoordinators = [moreCoordinator, homeCoordinator, favouritesCoordinator, leaderboardCoordinator]

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
                ), viewController: favouritesNavigationController
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
                viewController: leaderboardNavigationController
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

    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        presentingWindow: UIWindow,
        completion: (([HomeFlowBackwardEvent]) -> Void)?
    ) {
        self.presentingWindow = presentingWindow
        self.completion = completion
        let navigationController = UINavigationController()
        self._navigator = Navigator(navigationController: navigationController)
        self.childCoordinators = []
    }

    // MARK: - Life cycle
    func start() {
        presentingWindow.rootViewController = rootTabBarController
        rootTabBarController.selectHomeTab()
        presentingWindow.makeKeyAndVisible()
    }

    func stop() {
        childCoordinators.removeAll()
        completion?(backwardEvents)
    }

    func handleSwitchFlowAction(_ action: MainFlowSwitchAction) {
        switch action {
        case .shouldSwitchToMap(let pointIdentifier):
            guard let moveToFeedingPointEvent = homeCoordinator?.moveToFeedingPointEvent else { return }
            moveToFeedingPointEvent(pointIdentifier)
            rootTabBarController.selectHomeTab()
        case .shouldSwitchToFeeding(let feedDetails):
            guard let feedingDidStartedEvent = homeCoordinator?.feedingDidStartedEvent else { return }
            feedingDidStartedEvent(feedDetails)
            rootTabBarController.selectHomeTab()
        }
    }
}

private extension TabBarController {
    private enum Constant {
        static let homeViewIndex = 2
    }

    func selectHomeTab() {
        selectedViewController(index: Constant.homeViewIndex)
    }
}
