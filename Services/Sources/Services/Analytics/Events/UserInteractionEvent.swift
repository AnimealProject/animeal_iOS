import Foundation
import Firebase

/// Event to user action events
public final class UserInteractionEvent: AnalyticsEvent {
    public let eventName: String

    public init(
        eventName: String,
        screen: AnalyticsScreen,
        trackablePolicy: AnalyticsTrackablePolicy = .multipleTracking,
        targets: [AnalyticsTargetType],
        parameters: [String: String] = [:]
    ) {
        self.eventName = eventName

        var extendedParameters = parameters

        extendedParameters[AnalyticsKey.eventName] = eventName
        extendedParameters[AnalyticsParameterScreenName] = screen.description

        let className = String(describing: type(of: self))
        super.init(
            name: className,
            trackablePolicy: trackablePolicy,
            targets: targets,
            parameters: extendedParameters
        )
    }
}
