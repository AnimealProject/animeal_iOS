import Foundation
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore

final class FavouritesModel: FavouritesModelProtocol {
    typealias Context = DefaultsServiceHolder & NetworkServiceHolder & UserProfileServiceHolder & DataStoreServiceHolder
    
    // MARK: - Private properties
    private let context: Context
    private let mapper: FavouriteModelMappable
    
    // MARK: - Initialization
    init(
        context: Context = AppDelegate.shared.context,
        mapper: FavouriteModelMappable = FavouriteModelMapper()
    ) {
        self.context = context
        self.mapper = mapper
    }
    
    // MARK: - Requests
    func fetchFavourites() async throws -> [FavouritesModel.FavouriteContent] {
        let keys = animeal.Favourite.keys
        let predicate = keys.userId == context.profileService.getCurrentUser()?.userId
        let result = try await context.networkService.query(request: .list(animeal.Favourite.self, where: predicate))
        let content = result.map { favourite in
            self.mapper.mapFavourite(favourite)
        }

        return content
    }
    
    func fetchMediaContent(key: String, completion: ((Data?) -> Void)?) {
        context.dataStoreService.downloadData(
            key: key,
            options: .init(accessLevel: .guest)
        ) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    completion?(data)
                }
            case .failure(let error):
                // TODO: Handele error
                print(error.localizedDescription)
            }
        }
    }
}

extension FavouritesModel {
    struct FavouriteContent {
        let feedingPointId: String
        let header: Header
        let status: Status
        let isHighlighted: Bool
    }

    struct Header {
        let cover: String?
        let title: String
    }
    
    enum Status {
        case success(String)
        case attention(String)
        case error(String)
    }
}
