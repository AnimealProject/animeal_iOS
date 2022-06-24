import UIKit

public protocol ApplicationDelegateService {
    // required
    func registerApplication(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool
    // optional
    func applicationWillTerminate(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationWillResignActive(_ application: UIApplication)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func application(_ application: UIApplication, openURL: URL, options: [String: Any]) -> Bool
    func application(_ application: UIApplication, openURL: URL, sourceApplication: String?, annotation: Any) -> Bool

    // optional Push Notification methods
    func didRegisterForRemoteNotificationsWithDeviceToken(_ application: UIApplication, deviceToken: Data)
    func didFailToRegisterForRemoteNotificationsWithError(_ application: UIApplication, error: NSError)
    func didReceiveRemoteNotification(_ application: UIApplication, userInfo: [AnyHashable: Any])
    func handleActionWithIdentifierForRemoteNotification(
        _ application: UIApplication,
        identifier: String?,
        userInfo: [AnyHashable: Any],
        responseInfo: [AnyHashable: Any],
        completionHandler: () -> Void
    )
}

// MARK: - Optional methods implementation
public extension ApplicationDelegateService {
    func applicationWillTerminate(_: UIApplication) {}
    func applicationWillEnterForeground(_: UIApplication) {}
    func applicationWillResignActive(_: UIApplication) {}
    func applicationDidEnterBackground(_: UIApplication) {}
    func applicationDidBecomeActive(_: UIApplication) {}

    func didRegisterForRemoteNotificationsWithDeviceToken(_: UIApplication, deviceToken _: Data) {}
    func didFailToRegisterForRemoteNotificationsWithError(_: UIApplication, error _: NSError) {}
    func didReceiveRemoteNotification(_: UIApplication, userInfo _: [AnyHashable: Any]) {}
    func handleActionWithIdentifierForRemoteNotification(
        _: UIApplication,
        identifier _: String?,
        userInfo _: [AnyHashable: Any],
        responseInfo _: [AnyHashable: Any],
        completionHandler _: () -> Void
    ) {}

    func application(_: UIApplication, openURL _: URL, options _: [String: Any]) -> Bool {
        return false
    }

    func application(_: UIApplication, openURL _: URL, sourceApplication _: String?, annotation _: Any) -> Bool {
        return false
    }
}
