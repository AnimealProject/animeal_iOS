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

    /// Resolves every key in each batch to a URL, in parallel across batches and in order within each batch.
    public func getURLs<ID: Hashable>(for batches: [(id: ID, keys: [String])]) async -> [ID: [URL]] {
        await withTaskGroup(of: (ID, [URL]).self) { group in
            for batch in batches {
                group.addTask {
                    var urls: [URL] = []
                    for key in batch.keys {
                        if let url = try? await self.getURL(key: key) {
                            urls.append(url)
                        }
                    }
                    return (batch.id, urls)
                }
            }

            var result: [ID: [URL]] = [:]
            for await (id, urls) in group { result[id] = urls }
            return result
        }
    }
}
