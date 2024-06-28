import UIKit
import Services
import Amplify
import AWSS3StoragePlugin
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSDataStorePlugin

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

    struct URLSessionFactory: URLSessionBehaviorFactory {
        let configuration: URLSessionConfiguration
        let delegateQueue: OperationQueue?

        func makeSession(withDelegate delegate: URLSessionBehaviorDelegate?) -> URLSessionBehavior {
            let urlSessionDelegate = AMURLSessionDelegate(amplifyDelegate: delegate)
            let session = URLSession(
                                     configuration: configuration,
                                     delegate: urlSessionDelegate,
                                     delegateQueue: delegateQueue
                                    )
            return session
        }
    }

    static func makeDefault() -> URLSessionFactory {
        let configuration = URLSessionConfiguration.default
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.tlsMaximumSupportedProtocolVersion = .TLSv13
        let factory = URLSessionFactory(configuration: configuration, delegateQueue: nil)
        return factory
    }

    func configureAmplify() {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.add(plugin: AWSAPIPlugin(sessionFactory: AppDelegate.makeDefault()))
            try Amplify.configure()
            try Amplify.API.add(interceptor: UrlQueryPlusFixInterceptor(), for: "AdminQueries")
            Amplify.Logging.logLevel = .error
            logInfo("[APP] Amplify configured")
        } catch {
            logError("[APP] Failed to initialize Amplify with \(error)")
        }
    }

    func configureAppearance() {
        UINavigationBar.appearance().apply(style: .default)
    }
}

private class UrlQueryPlusFixInterceptor: URLRequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        if let urlString = request.url?.absoluteString,
           urlString.contains("listUsers"),
           let url = URL(string: urlString.replacingOccurrences(of: "+", with: "%2B")) {
            var requestCopy = URLRequest(
                url: url,
                cachePolicy: request.cachePolicy,
                timeoutInterval: request.timeoutInterval
            )
            requestCopy.allHTTPHeaderFields = request.allHTTPHeaderFields
            requestCopy.httpBody = request.httpBody
            return requestCopy
        }
        return request
    }
}
