import Foundation

public protocol DataStoreServiceHolder {
    var dataStoreService: DataStoreServiceProtocol { get }
}

/// Convenience typealias for the `handler` callback submitted during download data request
public typealias DataStoreDownloadDataHandler = (Result<Data, Error>) -> Void
public typealias DataStoreUploadProgressHandler = (Double) -> Void

public protocol DataStoreServiceProtocol: AnyObject {
    /// Retrieve the object from storage into memory.
    ///
    /// - Parameters:
    ///   - key: The unique identifier for the object in storage
    ///   - options: Options to adjust the behavior of this request
    /// - Returns: The downloaded data from the server
    /// - Throws: Error if it's a problem while getting the data
    ///
    func downloadData(
        key: String,
        options: DataStoreDownloadRequest.Options?
    ) async throws -> Data

    func uploadData(
        key: String,
        data: Data,
        progressListener: DataStoreUploadProgressHandler?
    ) async throws -> String

    func getURL(key: String?) async throws -> URL? 
}

extension DataStoreServiceProtocol {
    public func downloadData(
        key: String,
        options: DataStoreDownloadRequest.Options?,
        handler: DataStoreDownloadDataHandler?
    ) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await self.downloadData(key: key, options: options)
                handler?(.success(result))
            } catch {
                handler?(.failure(error))
            }
        }
    }
}
