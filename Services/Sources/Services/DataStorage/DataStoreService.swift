import Foundation

public protocol DataStoreServiceHolder {
    var dataStoreService: DataStoreServiceProtocol { get }
}

/// Convenience typealias for the `handler` callback submitted during download data request
public typealias DataStoreDownloadDataHandler = (Result<Data, Error>) -> Void
public typealias DataStoreUploadProgressHandler = (Double) -> Void

public protocol DataStoreServiceProtocol {
    /// Retrieve the object from storage into memory.
    ///
    /// - Parameters:
    ///   - key: The unique identifier for the object in storage
    ///   - options: Options to adjust the behavior of this request
    ///   - handler: Triggered when the download is complete
    /// - Returns: An operation object that provides notifications and actions related to the execution of the work
    func downloadData(
        key: String,
        options: DataStoreDownloadRequest.Options?,
        handler: DataStoreDownloadDataHandler?
    )

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
        options: DataStoreDownloadRequest.Options?
    ) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            downloadData(key: key, options: options) {
                continuation.resume(with: $0)
            }
        }
    }
}
