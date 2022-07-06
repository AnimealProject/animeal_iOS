import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics
import UIKit

public protocol AnalyticsServiceHolder {
    var analyticsService: AnalyticsServiceProtocol { get }
}

public protocol AnalyticsServiceProtocol {
    /// Logs an app events.
    func logEvent(_ event: AnalyticsEvent)
    /// Sets whether analytics collection is enabled for this app on this device.
    /// This setting is persisted across app sessions. By default it is enabled.
    func setEventTrackingEnabled(_ enabled: Bool)
}

/// AnalyticsService provides methods for logging events and setting user properties.
///
/// The logging system has two modes: default mode and debug mode. In default mode, only logs with log level Notice, Warning and Error will be sent to device. In debug mode, all logs will be sent to device.
///
/// Enable debug mode by passing the `-FIRDebugEnabled` argument to the application.
/// You can add this argument in the application's Xcode scheme. When debug mode is enabled via `-FIRDebugEnabled`,
/// further executions of the application will also be in debug mode. In order to return to default mode, you must explicitly disable
/// the debug mode with the application argument `-FIRDebugDisabled`.
///
/// Usage example:
///
///     AnalyticsService.logEvent(
///         UserInteractionEvent(
///              eventName: "Button tapped",
///              screen: AnalyticsScreen.screenForViewController(self),
///              trackablePolicy: .multipleTracking,
///              targets: [AnalyticsTargetType.firebase]
///         )
///      )
///     AppDelegate.shared.context.analyticsService.logEvent(
///         ScreenViewEvent(
///             screenName: AnalyticsScreen.screenForViewController(self).description,
///             trackablePolicy: .multipleTracking,
///             targets: [AnalyticsTargetType.firebase]
///         )
///     )
///
public class AnalyticsService {
    // MARK: - Private properties
    private var onceOnlyTrackableEventsStorage: [AnalyticsEventId] = []
    private let logger: Logger
    private let operationConcurrentQueue = DispatchQueue(
        label: "analyticsService.logging.queue",
        qos: .utility,
        attributes: [.concurrent]
    )

    // MARK: - Initialization
    public init(logger: Logger) {
        self.logger = logger
    }
}

// MARK: - AnalyticsServiceProtocol
extension AnalyticsService: AnalyticsServiceProtocol {
    public func logEvent(_ event: AnalyticsEvent) {
        if event.trackablePolicy == .trackOnceOnly {
            if onceOnlyTrackableEventsStorage.contains(event.eventId) {
                return
            } else {
                operationConcurrentQueue.sync {
                    onceOnlyTrackableEventsStorage.append(event.eventId)
                }
            }
        }
        #if DEBUG
            logger.debug("[Analytics] \(event.debugDescription) \(event)")
        #else
            operationConcurrentQueue.async { self.logEventInternal(event) }
        #endif
    }

    public func setEventTrackingEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }
}

// MARK: - ApplicationService
extension AnalyticsService: ApplicationDelegateService {
    public func registerApplication(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?
    ) -> Bool {
        initializeFirebase()
        initializeCrashlytics()
        return true
    }
}

// MARK: - Private API
private extension AnalyticsService {
    func initializeFirebase() {
       FirebaseApp.configure()
    }

    func initializeCrashlytics() {
        let crashlyticsUserId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        Crashlytics.crashlytics().setUserID(crashlyticsUserId)
    }

    func logEventInternal(_ event: AnalyticsEvent) {
        for target in event.targets {
            switch target {
            case .firebase:
                sendEventToFirebase(event)
            case .nonFatal:
                sendEventToCrashlytics(event)
            }
        }
    }

    func sendEventToFirebase(_ event: AnalyticsEvent) {
        var parameters: [String: Any] = [:]

        for param in event.parameters {
            parameters[param.key] = param.value
        }

        Analytics.logEvent(event.name, parameters: parameters)
    }

    func sendEventToCrashlytics(_ event: AnalyticsEvent) {
        Crashlytics.crashlytics().record(
            error: NSError(
                domain: "AnalyticsNonFatalEvent",
                code: 777,
                userInfo: event.parameters
            )
        )
    }
}
