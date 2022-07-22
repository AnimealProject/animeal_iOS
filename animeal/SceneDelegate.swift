//
//  SceneDelegate.swift
//  animeal
//
//  Created by Ihar Tsimafeichyk on 30/05/2022.
//

import UIKit
import UIComponents
import Style

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootTabBarController
        rootTabBarController.selectedViewController(
            index: rootTabBarController.items.firstIndex {
                $0.viewController is HomeViewController
            }
        )
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

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
                        title: L10n.TabBar.mode
                    )
                ), viewController: greenVC
            )
        ])
    }()
}
