// System
import Foundation

// SDK
import Services
import Amplify
import AWSDataStorePlugin

final class DataStoreService: DataStoreServiceProtocol {
    // MARK: - Private properties
    private let converter: DataStoreAmplifyConverting & AmplifyDataStoreConverting

    // MARK: - Initialization
    init(converter: DataStoreAmplifyConverting & AmplifyDataStoreConverting = DataStoreAmplifyConverter()) {
        self.converter = converter
    }

    func downloadData(
        key: String,
        options: DataStoreDownloadRequest.Options?
    ) async throws -> Data {
        do {
            let downloadTask = Amplify.Storage.downloadData(
                path: .fromString(storagePath(for: key, accessLevel: options?.accessLevel)),
                options: converter.convertDownloadDataRequestOptions(options)
            )
            let result = try await downloadTask.value

            return result
        } catch let error as StorageError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw DataStoreError.unknown("Something went wrong.")
        }
    }

    func uploadData(
        key: String,
        data: Data,
        progressListener: DataStoreUploadProgressHandler? = nil
    ) async throws -> String {
        do {
            let progressMappedListener: ((Progress) -> Void)? = { progress in
                progressListener?(progress.fractionCompleted)
            }
            let uploadTask = Amplify.Storage.uploadData(
                path: .fromString(storagePath(for: key, accessLevel: DataStoreAccessLevel.guest)),
                data: data
            )
            Task {
                for await progress in await uploadTask.progress {
                    progressMappedListener?(progress)
                }
            }
            let result = try await uploadTask.value
            return result
        } catch let error as StorageError {
            throw converter.convertAmplifyError(error)
        } catch {
            throw DataStoreError.unknown("Something went wrong.")
        }
    }

    // Amplify Gen 2 path API requires explicit prefix that Gen 1 added automatically.
    private func storagePath(for key: String, accessLevel: DataStoreAccessLevel?) -> String {
        switch accessLevel {
        case .protected: return "protected/\(key)"
        case .private: return "private/\(key)"
        default: return "public/\(key)"
        }
    }

    func getURL(key: String?) async throws -> URL? {
        guard let key, !key.isEmpty else { return nil }

        return try await Amplify.Storage.getURL(path: .fromString(storagePath(for: key, accessLevel: DataStoreAccessLevel.guest)))
    }
}
