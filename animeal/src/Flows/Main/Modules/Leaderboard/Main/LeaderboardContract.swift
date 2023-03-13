//
//  LeaderboardContract.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import Foundation

// MARK: - Coordinator
protocol LeaderboardCoordinatable {
    func routeTo(_ route: LeaderboardRoute)
}

enum LeaderboardRoute {
    case details(String)
}

// MARK: - Model
protocol LeaderboardModelProtocol: AnyObject {
    func fetchLeaderboard() async throws -> [LeaderboardContent]
}

// MARK: - View
@MainActor
protocol LeaderboardViewModelOutput: AnyObject {
    func populateLeaderboard(_ viewState: LeaderboardViewContentState)
}

enum LeaderboardViewContentState {
    case content([LeaderboardItem])
    case empty(String)
}

public protocol LeaderboardItem {
    // will be added soon
}

// MARK: - ViewModel
typealias LeaderboardViewModelProtocol = LeaderboardViewModelLifeCycle & LeaderboardViewInteraction & LeaderboardViewState

@MainActor
protocol LeaderboardViewModelLifeCycle: AnyObject {
    func load(showLoading: Bool)
}

@MainActor
protocol LeaderboardViewInteraction: AnyObject {
    func handleActionEvent(_ event: LeaderboardViewActionEvent)
}

@MainActor
protocol LeaderboardViewState: AnyObject { }

enum LeaderboardViewActionEvent {
    case tapPerson(String)
}
