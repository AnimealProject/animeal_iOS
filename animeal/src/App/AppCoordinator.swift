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
    private let authenticationService: AuthenticationServiceProtocol
    private let authChannelEventsPublisher: AuthChannelEventsPublisher?
    private let profileService: UserProfileServiceProtocol

    var navigator: Navigating { _navigator }

    // MARK: - Initialization
    init(
        scene: UIWindowScene,
        context: Context = AppDelegate.shared.context,
        authChannelEventsPublisher: AuthChannelEventsPublisher? = nil
    ) {
        self.scene = scene
        self.authenticationService = context.authenticationService
        self.profileService = context.profileService
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

        Task { @MainActor [weak self] in
            guard let self, let session = try? await self.authenticationService.fetchAuthSession()
            else { return }
            try? await self.profileService.fetchUserAttributes()
            let userValidationModel = profileService.getCurrentUserValidationModel()
            let isUserValidated = self.profileService
                .getCurrentUserValidationModel()
                .validated
            self.move(
                isSignedIn: session.isSignedIn,
                isCurrentUserValidated: isUserValidated,
                userMode: userValidationModel.userMode
            )
        }
    }

    func stop() { }
}

private extension AppCoordinator {
    func handleBackwardAction(_ action: HomeFlowBackwardAction) {
        switch action {
        case .shouldShowToast(let title):
            if let view = self.authWindow.rootViewController?.view {
                Toast.show(message: title, anchor: view)
            }
        case .needsAuthentication:
            profileService.prepareForAuthentication()
            Task { @MainActor in
                self.startAuthFlow()
            }
        }
    }

    @MainActor
    func move(isSignedIn: Bool, isCurrentUserValidated: Bool, userMode: UserMode?) {
        if userMode == .guest {
            startMainFlow()
        } else if isSignedIn, isCurrentUserValidated {
            startMainFlow()
        } else {
            startAuthFlow()
        }
    }

    func fetchAuthSession(completion: @escaping (Bool) -> Void) {
        authenticationService.fetchAuthSession { result in
            do {
                let session: AuthenticationSession = try result.get()
                completion(session.isSignedIn)
            } catch {
                logDebug("Fetch auth session failed with error - \(error)")
                completion(false)
            }
        }
    }

    @MainActor
    private func startMainFlow() {
        let mainCoordinator = MainCoordinator(
            presentingWindow: mainWindow,
            viewModel: MainCoordinatorViewModel(userProfileService: profileService)
        ) { [weak self] events in
            self?.childCoordinators.removeAll()

            var shouldRestartFlow = true
            events.forEach { event in
                switch event {
                case .event(let action):
                    if case .needsAuthentication = action {
                        shouldRestartFlow = false
                        self?.handleBackwardAction(action)
                    } else {
                        self?.homeFlowBackwardAction.append(action)
                    }
                }
            }

            if shouldRestartFlow {
                self?.start()
            }
        }
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }

    @MainActor
    private func startAuthFlow() {
        let authenticationCoordinator = AuthCoordinator(
            presentingWindow: authWindow
        ) { [weak self] in
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
