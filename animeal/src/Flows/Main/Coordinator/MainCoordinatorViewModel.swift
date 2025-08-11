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
