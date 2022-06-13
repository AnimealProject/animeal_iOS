import UIKit

extension UIViewController {
    public var customTabBarController: TabBarControllerProtocol? {
        var controller = parent
        while controller != nil {
            if let tabBarController = controller as? TabBarControllerProtocol {
                return tabBarController
            }
            controller = controller?.parent
        }
        return nil
    }
}
