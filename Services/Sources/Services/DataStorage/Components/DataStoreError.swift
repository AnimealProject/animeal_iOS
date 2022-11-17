import Foundation

public typealias DataStoreErrorDescription = String
public typealias DataStoreErrorRecoverySuggestion = String
public typealias DataStoreErrorField = String
public typealias DataStoreErrorKey = String

public enum DataStoreError {
    case accessDenied(DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case authError(DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case configuration(DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case httpStatusError(Int, DataStoreErrorRecoverySuggestion, Error? = nil)
    case keyNotFound(DataStoreErrorKey, DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case localFileNotFound(DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case service(DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
    case unknown(DataStoreErrorDescription, Error? = nil)
    case validation(DataStoreErrorKey, DataStoreErrorDescription, DataStoreErrorRecoverySuggestion, Error? = nil)
}

extension DataStoreError: Error {
    public var errorDescription: DataStoreErrorDescription {
        switch self {
        case .accessDenied(let errorDescription, _, _),
                .authError(let errorDescription, _, _),
                .configuration(let errorDescription, _, _),
                .service(let errorDescription, _, _),
                .localFileNotFound(let errorDescription, _, _),
                .keyNotFound(_, let errorDescription, _, _),
                .unknown(let errorDescription, _),
                .validation(_, let errorDescription, _, _):
            return errorDescription
        case .httpStatusError(let statusCode, _, _):
            return "The HTTP response status code is [\(statusCode)]."
        }
    }

    public var recoverySuggestion: DataStoreErrorRecoverySuggestion {
        switch self {
        case .accessDenied(_, let recoverySuggestion, _),
                .authError(_, let recoverySuggestion, _),
                .configuration(_, let recoverySuggestion, _),
                .localFileNotFound(_, let recoverySuggestion, _),
                .service(_, let recoverySuggestion, _),
                .validation(_, _, let recoverySuggestion, _),
                .httpStatusError(_, let recoverySuggestion, _),
                .keyNotFound(_, _, let recoverySuggestion, _):
            return recoverySuggestion
        case .unknown:
            return "Unexpected error occurred with message"
        }
    }

    public var underlyingError: Error? {
        switch self {
        case .accessDenied(_, _, let underlyingError),
             .authError(_, _, let underlyingError),
             .configuration(_, _, let underlyingError),
             .httpStatusError(_, _, let underlyingError),
             .keyNotFound(_, _, _, let underlyingError),
             .localFileNotFound(_, _, let underlyingError),
             .service(_, _, let underlyingError),
             .unknown(_, let underlyingError),
             .validation(_, _, _, let underlyingError):
            return underlyingError
        }
    }
}
