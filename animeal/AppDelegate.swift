import UIKit
import Services
import Amplify

protocol AppDelegateProtocol {
    var context: AppContext! { get }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AppDelegateProtocol {
    // swiftlint:disable force_cast
    static let shared: AppDelegateProtocol = UIApplication.shared.delegate as! AppDelegateProtocol
    // swiftlint:enable force_cast
    var context: AppContext!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        context = AppContext.context()
        context.applicationDelegateServices.forEach {
            _ = $0.registerApplication(application, didFinishLaunchingWithOptions: launchOptions)
        }

        do {
            try Amplify.configure()
            logInfo("Amplify configured")
        } catch {
            logError("Failed to initialize Amplify with \(error)")
        }

        logInfo("[APP] \(#function)")
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        logInfo("[APP] \(#function)")
        context.applicationDelegateServices.forEach {
            _ = $0.applicationWillTerminate(application)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}
