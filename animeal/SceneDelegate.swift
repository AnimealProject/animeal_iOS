//
//  SceneDelegate.swift
//  animeal
//
//  Created by Ihar Tsimafeichyk on 30/05/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AppCoordinatorHolder {
    var coordinator: AppCoordinatable?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let appCoordinator = AppCoordinator(scene: windowScene)
        coordinator = appCoordinator
        appCoordinator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
