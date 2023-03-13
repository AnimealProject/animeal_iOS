//
//  LeaderboardModuleAssembler.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import UIKit

@MainActor
final class LeaderboardModuleAssembler {
    private let coordinator: LeaderboardCoordinatable

    init(coordinator: LeaderboardCoordinatable) {
        self.coordinator = coordinator
    }

    func assemble() -> UIViewController {
        let model = LeaderboardModel()
        let viewModel = LeaderboardViewModel(coordinator: coordinator, model: model)
        let view = LeaderboardViewController(viewModel: viewModel)

        viewModel.onContentHaveBeenPrepared = { [weak view] viewState in
            view?.populateLeaderboard(viewState)
        }

        return view
    }
}
