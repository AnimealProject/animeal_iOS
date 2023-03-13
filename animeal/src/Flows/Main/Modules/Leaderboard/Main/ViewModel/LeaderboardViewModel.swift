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

    // MARK: - Initialization
    init(coordinator: LeaderboardCoordinatable, model: LeaderboardModelProtocol) {
        self.coordinator = coordinator
        self.model = model
    }

    // MARK: - Life cycle
    func load(showLoading: Bool) { }

    func handleActionEvent(_ event: LeaderboardViewActionEvent) { }
}
