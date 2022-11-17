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
        case .accessDenied(let errorDescription, let recoverySuggestion, let underlyingError):
            return .accessDenied(errorDescription, recoverySuggestion, underlyingError)
        case .authError(let errorDescription, let recoverySuggestion, let underlyingError):
            return .authError(errorDescription, recoverySuggestion, underlyingError)
        case .configuration(let errorDescription, let recoverySuggestion, let underlyingError):
            return .configuration(errorDescription, recoverySuggestion, underlyingError)
        case .httpStatusError(let status, let recoverySuggestion, let underlyingError):
            return .httpStatusError(status, recoverySuggestion, underlyingError)
        case .keyNotFound(let key, let errorDescription, let recoverySuggestion, let underlyingError):
            return .keyNotFound(key, errorDescription, recoverySuggestion, underlyingError)
        case .localFileNotFound(let errorDescription, let recoverySuggestion, let underlyingError):
            return .localFileNotFound(errorDescription, recoverySuggestion, underlyingError)
        case .service(let errorDescription, let recoverySuggestion, let underlyingError):
            return .service(errorDescription, recoverySuggestion, underlyingError)
        case .unknown(let errorDescription, let underlyingError):
            return .unknown(errorDescription, underlyingError)
        case .validation(let field, let errorDescription, let recoverySuggestion, let underlyingError):
            return .validation(field, errorDescription, recoverySuggestion, underlyingError)
        }
    }
}
