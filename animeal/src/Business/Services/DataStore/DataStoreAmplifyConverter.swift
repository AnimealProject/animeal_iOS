// System
import Foundation

// SDK
import Services
import Amplify
import AWSDataStorePlugin

protocol DataStoreAmplifyConverting {
    func convertAmplifyError(_ amplifyError: StorageError) -> Services.DataStoreError
}

protocol AmplifyDataStoreConverting {
    func convertDownloadDataRequestOptions(_ options: DataStoreDownloadRequest.Options?) -> StorageDownloadDataRequest.Options?
}

struct DataStoreAmplifyConverter: AmplifyDataStoreConverting, DataStoreAmplifyConverting {
    func convertDownloadDataRequestOptions(
        _ options: DataStoreDownloadRequest.Options?
    ) -> StorageDownloadDataRequest.Options? {
        guard let opt = options else { return nil }

        var accessLevel: StorageAccessLevel
        switch opt.accessLevel {
        case .private:
            accessLevel = .private
        case .guest:
            accessLevel = .guest
        case .protected:
            accessLevel = .protected
        }

        return StorageDownloadDataRequest.Options(
            accessLevel: accessLevel,
            targetIdentityId: opt.targetIdentityId
        )
    }

    func convertAmplifyError(_ amplifyError: StorageError) -> Services.DataStoreError {
        switch amplifyError {
        case let .accessDenied(errorDescription, recoverySuggestion, underlyingError):
            return .accessDenied(errorDescription, recoverySuggestion, underlyingError)
        case let .authError(errorDescription, recoverySuggestion, underlyingError):
            return .authError(errorDescription, recoverySuggestion, underlyingError)
        case let .configuration(errorDescription, recoverySuggestion, underlyingError):
            return .configuration(errorDescription, recoverySuggestion, underlyingError)
        case let .httpStatusError(status, recoverySuggestion, underlyingError):
            return .httpStatusError(status, recoverySuggestion, underlyingError)
        case let .keyNotFound(key, errorDescription, recoverySuggestion, underlyingError):
            return .keyNotFound(key, errorDescription, recoverySuggestion, underlyingError)
        case let .localFileNotFound(errorDescription, recoverySuggestion, underlyingError):
            return .localFileNotFound(errorDescription, recoverySuggestion, underlyingError)
        case let .service(errorDescription, recoverySuggestion, underlyingError):
            return .service(errorDescription, recoverySuggestion, underlyingError)
        case let .unknown(errorDescription, underlyingError):
            return .unknown(errorDescription, underlyingError)
        case let .validation(field, errorDescription, recoverySuggestion, underlyingError):
            return .validation(field, errorDescription, recoverySuggestion, underlyingError)
        }
    }
}
