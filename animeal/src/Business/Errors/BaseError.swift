import Foundation

class BaseError: NSError, LocalizedError {
    private enum Constants {
        static let domain = "AnimealErrorDomain"
    }

    enum Code: Int {
        case unknown
        case unexpected
        case noInternet
        case timeout
        case notFound
        case entityExists
        case notAuthorized
        case serverError

        static func from(nsError: NSError) -> Self {
            switch (nsError .domain, nsError.code) {
            case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet),
                    (NSURLErrorDomain, NSURLErrorInternationalRoamingOff),
                    (NSURLErrorDomain, NSURLErrorCannotConnectToHost),
                    (NSURLErrorDomain, NSURLErrorDataNotAllowed),
                    (NSURLErrorDomain, NSURLErrorNetworkConnectionLost),
                    (NSURLErrorDomain, NSURLErrorSecureConnectionFailed),
                    (NSURLErrorDomain, NSURLErrorCannotFindHost): return .noInternet
            case (NSURLErrorDomain, NSURLErrorTimedOut): return .timeout
            default: return .unknown
            }
        }

        static func from(statusCode: Int) -> Self? {
            switch statusCode {
            case 404: return .notFound
            case 409: return .entityExists
            case 401: return .notAuthorized
            case 408, 504: return .timeout
            case 500...: return .serverError
            default: return .none
            }
        }
    }

    let errorCode: Code

    init(
        localizedDescription: String,
        failureReason: String? = nil,
        code: Code = .unknown,
        userInfo: [String: Any?]? = nil
    ) {
        self.errorCode = code

        let info = [
            NSLocalizedDescriptionKey: localizedDescription,
            NSLocalizedFailureReasonErrorKey: failureReason
        ].merging(userInfo ?? [:]) { $1 }
        .compactMapValues { $0 }

        super.init(
            domain: Constants.domain,
            code: errorCode.rawValue,
            userInfo: info
        )
    }

    init(error: NSError) {
        self.errorCode = .from(nsError: error)

        super.init(
            domain: error.domain,
            code: error.code,
            userInfo: error.userInfo
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    func asBaseError(failureReason: String? = nil, code: BaseError.Code = .unknown) -> BaseError {
        BaseError(localizedDescription: self, failureReason: failureReason, code: code)
    }
}
