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
        let gqlRequest = request.convertToGraphQLRequest()
        let operation = gqlRequest.decodePath ?? String(describing: Response.self)
        logDebug("[Network] → \(operation) variables: \(stringify(gqlRequest.variables))")
        do {
            let result = try await Amplify.API.query(request: gqlRequest)
            switch result {
            case .success(let response):
                logDebug("[Network] ← \(operation) response: \(stringify(response))")
                return response
            case .failure(let error):
                logError("[Network] ← \(operation) error: \(error)")
                throw mapAmplifyError(error)
            }
        } catch {
            throw mapAmplifyError(error)
        }
    }

    // MARK: - Private Methods

    private func stringify(_ value: Any?, limit: Int = 1000) -> String {
        guard let value else { return "nil" }
        let raw: String
        if let encodable = value as? Encodable,
           let data = try? JSONEncoder().encode(encodable),
           let json = String(data: data, encoding: .utf8) {
            raw = json
        } else {
            raw = String(describing: value)
        }
        return raw.count > limit ? raw.prefix(limit) + "…" : raw
    }

    private func mapAmplifyError(_ error: Error) -> BaseError {
        let nsError = error as NSError

        // Check if it's a network-related error
        if nsError.domain == NSURLErrorDomain {
            return BaseError.init(error: nsError)
        }

        // Check if it's an Amplify API error
        if let amplifyError = error as? APIError {
            return amplifyError.errorDescription.asBaseError(
                failureReason: amplifyError.localizedDescription,
                code: BaseError.Code.from(nsError: nsError)
            )
        }

        // Default case - return a generic error
        return L10n.Errors.somethingWrong.asBaseError(
            failureReason: error.localizedDescription,
            code: .unknown
        )
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
