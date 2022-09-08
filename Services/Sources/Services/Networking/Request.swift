import Foundation

public struct Request<R: Decodable> {
    public let document: String
    public let apiName: String?
    public let variables: [String: Any]?
    public let responseType: R.Type
    public let decodePath: String?

    public init(
        document: String,
        apiName: String? = nil,
        variables: [String: Any]? = nil,
        responseType: R.Type,
        decodePath: String? = nil
    ) {
        self.document = document
        self.apiName = apiName
        self.variables = variables
        self.responseType = responseType
        self.decodePath = decodePath
    }
}
