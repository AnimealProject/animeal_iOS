import UIKit
import Services
import Amplify
import AWSS3StoragePlugin
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSDataStorePlugin
import AWSCore

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
        configureAmplify()
        configureAppearance()

        context = AppContext.context()
        context.applicationDelegateServices.forEach {
            _ = $0.registerApplication(application, didFinishLaunchingWithOptions: launchOptions)
        }
        logInfo("[APP] \(#function)")

        // For Debug purposes
        // AWSDDLog.sharedInstance.logLevel = .verbose
        // AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

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

private extension AppDelegate {
    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            Amplify.Logging.logLevel = .verbose
            logInfo("[APP] Amplify configured")
        } catch {
            logError("[APP] Failed to initialize Amplify with \(error)")
        }
    }
    
    func configureAppearance() {
        UINavigationBar.appearance().apply(style: .default)
    }
}
