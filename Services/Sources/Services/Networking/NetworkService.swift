import Foundation

public protocol NetworkServiceHolder {
    var networkService: NetworkServiceProtocol { get }
}

public protocol NetworkServiceProtocol {
    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response
    func query<Response: Decodable>(request: Request<Response>) async throws -> Response
}

public extension NetworkServiceProtocol {
    func mutate<Response: Decodable>(
        request: Request<Response>,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await mutate(request: request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    func query<Response: Decodable>(
        request: Request<Response>,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        Task {
            do {
                let result = try await query(request: request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
