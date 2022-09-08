import Foundation

public protocol NetworkServiceHolder {
    var networkService: NetworkServiceProtocol { get }
}

public protocol NetworkServiceProtocol {
    func query<R: Decodable>(request: Request<R>, completion: @escaping (Result<R, Error>) -> Void)
    func mutate<R: Decodable>(request: Request<R>, completion: @escaping (Result<R, Error>) -> Void)
}
