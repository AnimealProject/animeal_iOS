//
//  LeaderboardViewModel.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import Foundation

final class LeaderboardViewModel: LeaderboardViewModelProtocol {
    // MARK: - Dependencies
    private let model: LeaderboardModelProtocol
    private let coordinator: LeaderboardCoordinatable

    // MARK: - State
    var onContentHaveBeenPrepared: ((LeaderboardViewContentState) -> Void)?

    // MARK: - Initialization
    init(coordinator: LeaderboardCoordinatable, model: LeaderboardModelProtocol) {
        self.coordinator = coordinator
        self.model = model
    }

    // MARK: - Life cycle
    func load(showLoading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.onContentHaveBeenPrepared?(.empty(L10n.LeaderBoard.empty))
        }
    }

    func handleActionEvent(_ event: LeaderboardViewActionEvent) { }
}
