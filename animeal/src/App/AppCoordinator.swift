// System
import UIKit

// SDK
import Services

protocol AppCoordinatorHolder {
    var coordinator: AppCoordinatable? { get }
}

protocol AppCoordinatable: Coordinatable { }

final class AppCoordinator: AppCoordinatable {
    // MARK: - Private properties
    private let navigator: Navigating

    private var childCoordinators: [Coordinatable]
    private lazy var authWindow = UIWindow(windowScene: scene)
    private lazy var mainWindow = UIWindow(windowScene: scene)

    // MARK: - Dependencies
    private let scene: UIWindowScene
    private let authentificationService: AuthenticationServiceProtocol

    // MARK: - Initialization
    init(
        scene: UIWindowScene,
        authentificationService: AuthenticationServiceProtocol
         = AppDelegate.shared.context.authenticationService
    ) {
        self.scene = scene
        self.authentificationService = authentificationService
        self.navigator = Navigator(navigationController: UINavigationController())
        self.childCoordinators = []
    }

    // MARK: - Life cycle
    func start() {
        if authentificationService.isSignedIn {
            let mainCoordinator = MainCoordinator(presentingWindow: mainWindow) { }
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
