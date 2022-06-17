import Foundation
import UIKit
import UIComponents
import Style

enum TabBarControllerAssembler {
    static func assembly() -> UIViewController {
        let systemGray5VC = UIViewController()
        systemGray5VC.view.backgroundColor = .systemGray5

        let systemGray4VC = UIViewController()
        systemGray4VC.view.backgroundColor = .systemGray4

        let systemGray3VC = UIViewController()
        systemGray3VC.view.backgroundColor = .systemGray3

        let systemGray2VC = UIViewController()
        systemGray2VC.view.backgroundColor = .systemGray2

        let systemGrayVC = UIViewController()
        systemGrayVC.view.backgroundColor = .systemGray

        return TabBarController(items: [
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.glass.image,
                        title: "Search"
                    )
                ), viewController: systemGray5VC
            ),

            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.heart.image,
                        title: "Favourites"
                    )
                ), viewController: systemGray4VC
            ),
            TabBarControllerItem(
                tabBarItemView: HomeTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.home.image
                    )
                ), viewController: systemGray3VC
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.podium.image,
                        title: "LeaderBoard"
                    )
                ), viewController: systemGray2VC
            ),
            TabBarControllerItem(
                tabBarItemView: PlainTabBarItemView(
                    model: TabBarItemViewModel(
                        icon: Asset.Images.more.image,
                        title: "More"
                    )
                ), viewController: systemGrayVC
            )
        ])
    }
}
