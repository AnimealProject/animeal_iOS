import Foundation

public typealias AuthenticationErrorDescription = String
public typealias AuthenticationRecoverySuggestion = String
public typealias AuthenticationField = String

public enum AuthenticationError {
    /// Caused by issue in the way auth category is configured
    case configuration(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused by some error in the underlying service. Check the associated error for more details.
    case service(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused by an unknown reason
    case unknown(AuthenticationErrorDescription, Error? = nil)

    /// Caused when one of the input field is invalid
    case validation(AuthenticationField, AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused when the current session is not authorized to perform an operation
    case notAuthorized(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused when an operation is not valid with the current state of Auth category
    case invalidState(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused when an operation needs the user to be in signedIn state
    case signedOut(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)

    /// Caused when a session is expired and needs the user to be re-authenticated
    case sessionExpired(AuthenticationErrorDescription, AuthenticationRecoverySuggestion, Error? = nil)
}

extension AuthenticationError: Error {
    public var underlyingError: Error? {
        switch self {
        case .configuration(_, _, let underlyingError),
             .service(_, _, let underlyingError),
             .unknown(_, let underlyingError),
             .validation(_, _, _, let underlyingError),
             .notAuthorized(_, _, let underlyingError),
             .sessionExpired(_, _, let underlyingError),
             .signedOut(_, _, let underlyingError),
             .invalidState(_, _, let underlyingError):
            return underlyingError
        }
    }

    public var errorDescription: AuthenticationErrorDescription {
        switch self {
        case .configuration(let errorDescription, _, _),
             .service(let errorDescription, _, _),
             .validation(_, let errorDescription, _, _),
             .notAuthorized(let errorDescription, _, _),
             .signedOut(let errorDescription, _, _),
             .sessionExpired(let errorDescription, _, _),
             .invalidState(let errorDescription, _, _):
            return errorDescription
        case .unknown(let errorDescription, _):
            return "Unexpected error occurred with message: \(errorDescription)"
        }
    }

    public var recoverySuggestion: AuthenticationRecoverySuggestion {
        switch self {
        case .configuration(_, let recoverySuggestion, _),
             .service(_, let recoverySuggestion, _),
             .validation(_, _, let recoverySuggestion, _),
             .notAuthorized(_, let recoverySuggestion, _),
             .signedOut(_, let recoverySuggestion, _),
             .sessionExpired(_, let recoverySuggestion, _),
             .invalidState(_, let recoverySuggestion, _):
            return recoverySuggestion
        case .unknown:
            return "An unknown error occurred"
        }
    }

    public var detailedError: AuthenticationDetailedError? {
        guard let error = underlyingError as? AuthenticationDetailedError
        else { return nil }
        return error
    }

    public init(
        errorDescription: AuthenticationErrorDescription = "An unknown error occurred",
        recoverySuggestion: AuthenticationRecoverySuggestion = "",
        error: Error
    ) {
        if let error = error as? Self {
            self = error
        } else {
            self = .unknown(errorDescription, error)
        }
    }
}
