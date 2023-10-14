//
//  LeaderboardCoordinator.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import UIKit

@MainActor
final class LeaderboardCoordinator: Coordinatable {
    // MARK: - Dependencies
    internal var navigator: Navigating
    private let completion: ((HomeFlowBackwardEvent?) -> Void)?
    private var backwardEvent: HomeFlowBackwardEvent?

    // MARK: - Initialization
    init(navigator: Navigator, completion: ((HomeFlowBackwardEvent?) -> Void)? = nil) {
        self.navigator = navigator
        self.completion = completion
    }

    // MARK: - Life cycle
    func start() {
        let leaderboardViewController = LeaderboardModuleAssembler(coordinator: self).assemble()
        navigator.push(leaderboardViewController, animated: false, completion: nil)
    }

    func stop() {
        completion?(backwardEvent)
    }
}

extension LeaderboardCoordinator: LeaderboardCoordinatable {
    func routeTo(_ route: LeaderboardRoute) { }
}
