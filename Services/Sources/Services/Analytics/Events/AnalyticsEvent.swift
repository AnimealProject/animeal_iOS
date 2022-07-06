import Foundation

public typealias AnalyticsEventId = String

public class AnalyticsEvent {
    public let name: String
    public let trackablePolicy: AnalyticsTrackablePolicy
    public let targets: [AnalyticsTargetType]
    public let parameters: [String: String]

    var debugDescription: String {
        return eventId
    }

    var eventId: AnalyticsEventId {
        let prefix: String = name.description.replacingOccurrences(of: " ", with: "")
        let suffix: String = parameters.description
        let result = "\(prefix)_\(suffix)"
        return result
    }

    public init(
        name: String,
        trackablePolicy: AnalyticsTrackablePolicy = .multipleTracking,
        targets: [AnalyticsTargetType],
        parameters: [String: String] = [:]
    ) {
        self.name = name
        self.trackablePolicy = trackablePolicy
        self.targets = targets
        self.parameters = parameters
    }
}

public enum AnalyticsTargetType {
    case firebase
    case nonFatal

    public static var `default`: [AnalyticsTargetType] {
        return [.firebase]
    }
}

public enum AnalyticsTrackablePolicy {
    /// mostly used during sign up and welcome
    case trackOnceOnly
    /// each time event appeared it will be sent to targets
    case multipleTracking
}

public enum AnalyticsKey {
    public static let eventName: String = "eventName"
    public static let state: String = "state"
    public static let clientSessionId: String = "csid"
    public static let eventCategory: String = "eventCategory"
    public static let elementName: String = "elementName"
}
