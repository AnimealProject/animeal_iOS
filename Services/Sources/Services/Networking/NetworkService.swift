import Foundation

public protocol NetworkServiceHolder {
    var networkService: NetworkServiceProtocol { get }
}

public protocol NetworkServiceProtocol {
    func query<Response: Decodable>(request: Request<Response>, completion: @escaping (Result<Response, Error>) -> Void)
    func mutate<Response: Decodable>(request: Request<Response>, completion: @escaping (Result<Response, Error>) -> Void)
}

public extension NetworkServiceProtocol {
    func query<Response: Decodable>(request: Request<Response>) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            query(request: request) { continuation.resume(with: $0) }
        }
    }
    
    func mutate<Response: Decodable>(request: Request<Response>) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            mutate(request: request) { continuation.resume(with: $0) }
        }
    }
}
