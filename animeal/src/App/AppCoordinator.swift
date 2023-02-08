// System
import UIKit

// SDK
import Services
import Amplify
import UIComponents

protocol AppCoordinatorHolder {
    var coordinator: AppCoordinatable? { get }
}

protocol AppCoordinatable: Coordinatable { }

final class AppCoordinator: AppCoordinatable {
    typealias Context = AuthenticationServiceHolder & UserProfileServiceHolder

    // MARK: - Private properties
    private let _navigator: Navigating

    private var childCoordinators: [Coordinatable]
    private lazy var authWindow = UIWindow(windowScene: scene)
    private lazy var mainWindow = UIWindow(windowScene: scene)
    private lazy var loaderWindow = UIWindow(windowScene: scene)
    private var homeFlowBackwardAction: [HomeFlowBackwardAction] = []

    // MARK: - Dependencies
    private let scene: UIWindowScene
    private let context: Context
    private let authChannelEventsPublisher: AuthChannelEventsPublisher?

    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        scene: UIWindowScene,
        context: Context = AppDelegate.shared.context,
        authChannelEventsPublisher: AuthChannelEventsPublisher? = nil
    ) {
        self.scene = scene
        self.context = context
        self._navigator = Navigator(navigationController: UINavigationController())
        self.childCoordinators = []

        if authChannelEventsPublisher == nil,
           let publisher = context.profileService.getCurrentUserValidationModel() as? AuthChannelEventsPublisher {
            self.authChannelEventsPublisher = publisher
        } else {
            self.authChannelEventsPublisher = authChannelEventsPublisher
        }
    }

    // MARK: - Life cycle
    func start() {
        loaderWindow.rootViewController = LoaderViewController()
        loaderWindow.makeKeyAndVisible()

        // Fetching AuthSession to check if user is isSignedIn
        fetchAuthSession { [weak self] isSignedIn in
            guard let self = self else { return }
            // Fetching user attributes to prefill validationModel,
            self.context.profileService.fetchUserAttributes { _ in
                // AsyncAfter added to give a chance to validationModel handle fetchUserAttributes event.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.handler(
                        isSignedIn: isSignedIn,
                        isCurrentUserValidated: self.context.profileService.getCurrentUserValidationModel().validated
                    )
                }
            }
        }
    }

    func stop() { }
}

private extension AppCoordinator {
    @MainActor
    private func handler(isSignedIn: Bool, isCurrentUserValidated: Bool) {
        if isSignedIn, isCurrentUserValidated {
            let mainCoordinator = MainCoordinator(presentingWindow: mainWindow) { [weak self] events in
                guard let self = self else { return }
                self.childCoordinators.removeAll()
                self.start()
                events.forEach { event in
                    switch event {
                    case .event(let action):
                        self.homeFlowBackwardAction.append(action)
                    }
                }
            }
            childCoordinators.append(mainCoordinator)
            mainCoordinator.start()
        } else {
            let authenticationCoordinator = AuthCoordinator(presentingWindow: authWindow) { [weak self] in
                self?.childCoordinators.removeAll()
                self?.start()
            }
            childCoordinators.append(authenticationCoordinator)
            authenticationCoordinator.start()
            homeFlowBackwardAction.forEach { action in
                handleBackwardAction(action)
            }
            homeFlowBackwardAction.removeAll()
        }
    }

    private func fetchAuthSession(completion: @escaping (Bool) -> Void) {
        context.authenticationService.fetchAuthSession { result in
            do {
                let session: AuthenticationSession = try result.get()
                completion(session.isSignedIn)
            } catch {
                logDebug("Fetch auth session failed with error - \(error)")
                completion(false)
            }
        }
    }

    func handleBackwardAction(_ action: HomeFlowBackwardAction) {
        switch action {
        case .shouldShowToast(let title):
            if let view = self.authWindow.rootViewController?.view {
                Toast.show(message: title, anchor: view)
            }
        }
    }
}

extension AppCoordinator: AuthChannelEventsListener {
    @MainActor
    func listenAuthChannelEvents(event: AuthChannelEvents) {
        switch event {
        case .sessionExpired:
            start()
        }
    }
}

private final class LoaderViewController: BaseViewController, ActivityDisplayable {
    let activityPresenter = ActivityIndicatorPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = designEngine.colors.backgroundPrimary
        displayActivityIndicator()
    }
}
