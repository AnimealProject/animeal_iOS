// System
import UIKit

// SDK
import Common
import Services
import Amplify

final class NetworkService: NetworkServiceProtocol {
    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response {
        do {
            let result = try await Amplify.API.mutate(request: request.convertToGraphQLRequest())
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw mapAmplifyError(error)
            }
        } catch {
            throw mapAmplifyError(error)
        }
    }

    func query<Response: Decodable>(request: Request<Response>) async throws -> Response {
        do {
            let result = try await Amplify.API.query(request: request.convertToGraphQLRequest())
            
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw mapAmplifyError(error)
            }
        } catch {
            throw mapAmplifyError(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func mapAmplifyError(_ error: Error) -> BaseError {
        let nsError = error as NSError
        
        // Check if it's a network-related error
        if nsError.domain == NSURLErrorDomain {
            return mapNetworkError(nsError)
        }
        
        // Check if it's an Amplify API error
        if let amplifyError = error as? APIError {
            return mapAmplifyAPIError(amplifyError)
        }
        
        // Default case - return a generic error
        return L10n.Errors.somthingWrong.asBaseError(
            failureReason: error.localizedDescription,
            code: .unknown
        )
    }
    
    private func mapNetworkError(_ error: NSError) -> BaseError {
        switch error.code {
        case NSURLErrorNotConnectedToInternet,
             NSURLErrorInternationalRoamingOff,
             NSURLErrorCannotConnectToHost,
             NSURLErrorDataNotAllowed,
             NSURLErrorNetworkConnectionLost,
             NSURLErrorSecureConnectionFailed,
             NSURLErrorCannotFindHost:
            return "No internet connection. Please check your network settings and try again.".asBaseError(
                failureReason: error.localizedDescription,
                code: .noInternet
            )
        case NSURLErrorTimedOut:
            return "Request timed out. Please try again.".asBaseError(
                failureReason: error.localizedDescription,
                code: .timeout
            )
        default:
            return "Network error occurred. Please try again.".asBaseError(
                failureReason: error.localizedDescription,
                code: .unknown
            )
        }
    }
    
    private func mapAmplifyAPIError(_ error: APIError) -> BaseError {
        switch error {
        case .operationError:
            return "Request was cancelled.".asBaseError(
                failureReason: error.localizedDescription,
                code: .unknown
            )
        case .networkError(let errorDescription, let userInfo, let anyError):
            if let networkError = anyError {
                return mapNetworkError(networkError as NSError)
            } else {
                return "Network error occurred. Please try again.".asBaseError(
                    failureReason: errorDescription,
                    code: .noInternet
                )
            }
        default:
            return L10n.Errors.somthingWrong.asBaseError(
                failureReason: error.localizedDescription,
                code: .unknown
            )
        }
    }
    
    private func mapHTTPError(statusCode: Int, error: String) -> BaseError {
        switch statusCode {
        case 401:
            return "Authentication failed. Please log in again.".asBaseError(
                failureReason: error,
                code: .notAuthorized
            )
        case 404:
            return "The requested resource was not found.".asBaseError(
                failureReason: error,
                code: .notFound
            )
        case 409:
            return "Resource already exists.".asBaseError(
                failureReason: error,
                code: .entityExists
            )
        case 408, 504:
            return "Request timed out. Please try again.".asBaseError(
                failureReason: error,
                code: .timeout
            )
        case 500...:
            return "Server error occurred. Please try again later.".asBaseError(
                failureReason: error,
                code: .serverError
            )
        default:
            return "An error occurred. Please try again.".asBaseError(
                failureReason: error,
                code: .unknown
            )
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
