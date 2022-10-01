// System
import UIKit

// SDK
import Services
import Amplify
import AWSDataStorePlugin
import AWSAPIPlugin
import AWSPluginsCore
import UIComponents

final class NetworkService: NetworkServiceProtocol {
    func query<R: Decodable>(request: Request<R>, completion: @escaping (Result<R, Error>) -> Void) {
        _ = Amplify.API.query(request: request.convertToGraphQLRequest()) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let modelData):
                    completion(.success(modelData))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func mutate<R: Decodable>(request: Request<R>, completion: @escaping (Result<R, Error>) -> Void) {
        _ = Amplify.API.mutate(request: request.convertToGraphQLRequest()) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let modelData):
                    completion(.success(modelData))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension NetworkService: ApplicationDelegateService {
    func registerApplication(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [AnyHashable: Any]?
    ) -> Bool {
        do {
            let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: dataStorePlugin)
            logInfo("Amplify add AWSDataStorePlugin")
            try Amplify.add(plugin: AWSAPIPlugin())
            logInfo("Amplify add AWSAPIPlugin")
        } catch {
            logError("Failed to add AWSDataStorePlugin and AWSAPIPlugin plugins with \(error)")
        }

        return true
    }
}
