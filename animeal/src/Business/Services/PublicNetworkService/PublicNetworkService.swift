// System
import UIKit

// SDK
import Common
import Services
import Amplify

final class PublicNetworkService: NetworkServiceProtocol {

    func query<Response: Decodable>(request: Request<Response>) async throws -> Response {
        do {
            // Guest user - always use API Key
            let result = try await Amplify.API.query(
                request: request.convertToGraphQLRequest(authMode: .apiKey)
            )

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

    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response {
        // Guest users cannot mutate
        throw "Mutations not allowed for public access".asBaseError(
            failureReason: "Guest users cannot modify data",
            code: .unknown
        )
    }

    // MARK: - Private Methods

    private func mapAmplifyError(_ error: Error) -> BaseError {
        let nsError = error as NSError

        if nsError.domain == NSURLErrorDomain {
            return BaseError.init(error: nsError)
        }

        if let amplifyError = error as? APIError {
            return amplifyError.errorDescription.asBaseError(
                failureReason: amplifyError.localizedDescription,
                code: BaseError.Code.from(nsError: nsError)
            )
        }

        return L10n.Errors.somethingWrong.asBaseError(
            failureReason: error.localizedDescription,
            code: .unknown
        )
    }
}
