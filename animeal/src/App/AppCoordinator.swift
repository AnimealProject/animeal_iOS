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
    private let navigator: Navigating

    private var childCoordinators: [Coordinatable]
    private lazy var authWindow = UIWindow(windowScene: scene)
    private lazy var mainWindow = UIWindow(windowScene: scene)
    private lazy var loaderWindow = UIWindow(windowScene: scene)

    // MARK: - Dependencies
    private let scene: UIWindowScene
    private let context: Context

    // MARK: - Initialization
    init(
        scene: UIWindowScene,
        context: Context = AppDelegate.shared.context
    ) {
        self.scene = scene
        self.context = context
        self.navigator = Navigator(navigationController: UINavigationController())
        self.childCoordinators = []
    }

    // MARK: - Life cycle
    func start() {
        loaderWindow.rootViewController = LoaderViewController()
        loaderWindow.makeKeyAndVisible()

        // We are fetching user attributes to check if user validated, or not.
        context.profileService.fetchUserAttributes { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.handler(
                    isSignedIn: self.context.authenticationService.isSignedIn,
                    isCurrentUserValidated: self.context.profileService.getCurrentUserValidationModel().validated
                )
            }
        }
    }

    @MainActor
    private func handler(isSignedIn: Bool, isCurrentUserValidated: Bool) {
        if isSignedIn, isCurrentUserValidated {
            let mainCoordinator = MainCoordinator(presentingWindow: mainWindow) { [weak self] in
                self?.childCoordinators.removeAll()
                self?.start()
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
         }
    }

    func stop() { }
}

private final class LoaderViewController: BaseViewController, ActivityDisplayable {
    let activityPresenter = ActivityIndicatorPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = designEngine.colors.backgroundPrimary.uiColor
        displayActivityIndicator()
    }
}
