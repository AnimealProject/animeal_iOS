import Services
import UIComponents

protocol MainCoordinatorViewModelProtocol {
    func canShowTab(with identifier: TabIdentifier) -> Bool
}

final class MainCoordinatorViewModel: MainCoordinatorViewModelProtocol {
    let userProfileService: UserProfileServiceProtocol

    init(userProfileService: UserProfileServiceProtocol) {
        self.userProfileService = userProfileService
    }

    func canShowTab(with identifier: TabIdentifier) -> Bool {
        guard userProfileService.getCurrentUserValidationModel().userMode == .guest else {
            return true
        }

        switch identifier {
        case .home, .more:
            return true
        case .leaderBoard, .search, .favorites:
            return false
        }
    }
}

extension MainCoordinatorViewModel {
    enum AccessibilityID {
        static let searchTab = "search_tab"
        static let favouritesTab = "favourites_tab"
        static let homeTab = "home_tab"
        static let leaderboardTab = "leaderboard_tab"
        static let moreTab = "more_tab"
    }
}
