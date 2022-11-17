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
        options: DataStoreDownloadRequest.Options?,
        handler: DataStoreDownloadDataHandler?
    ) {
        let operation = Amplify.Storage.downloadData(
            key: key,
            options: converter.convertDownloadDataRequestOptions(options),
            progressListener: nil,
            resultListener: { [weak self] (event) in
                guard let self = self else { return }
                switch event {
                case let .success(data):
                    handler?(.success(data))
                case let .failure(storageError):
                    handler?(.failure(self.converter.convertAmplifyError(storageError)))
                }
            }
        )
    }
}
