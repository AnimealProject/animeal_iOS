//
//  LeaderboardModel.swift
//  animeal
//
//  Created by Ilya Biltuev on 13.03.2023.
//

import Foundation

final class LeaderboardModel: LeaderboardModelProtocol {
    func fetchLeaderboard() async throws -> [LeaderboardContent] {
        return [LeaderboardContent]() // to be replaced with actual data request
    }
}

struct LeaderboardContent { }
