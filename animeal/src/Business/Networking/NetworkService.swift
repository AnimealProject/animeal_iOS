// System
import UIKit

// SDK
import Services
import Amplify

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
