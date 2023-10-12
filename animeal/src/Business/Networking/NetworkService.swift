// System
import UIKit

// SDK
import Common
import Services
import Amplify

final class NetworkService: NetworkServiceProtocol {
    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response {
        let result = try await Amplify.API.mutate(request: request.convertToGraphQLRequest())

        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func query<Response: Decodable>(request: Request<Response>) async throws -> Response {
        let result = try await Amplify.API.query(request: request.convertToGraphQLRequest())
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}

extension NetworkServiceProtocol {
    func subscribe<R: Decodable>(
        request: Request<R>,
        valueListener: ((Result<R, Error>) -> Void)?
    ) -> AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<R>> {
        let subscription = Amplify.API.subscribe(request: request.convertToGraphQLRequest())
        Task {
            do {
                for try await subscriptionEvent in subscription {
                    switch subscriptionEvent {
                    case .connection:
                        break
                    case .data(let result):
                        switch result {
                        case .success(let modelData):
                            valueListener?(.success(modelData))
                        case .failure(let error):
                            valueListener?(.failure(error))
                        }
                    }
                }
            } catch {
                logError("Subscription has terminated with \(error)")
            }
        }
        return subscription
    }
}
