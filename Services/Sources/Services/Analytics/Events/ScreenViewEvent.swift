import Foundation
import Firebase

/// Event to manualy manually log screen_view events whether or not automatic tracking is enabled.
/// You can log these events in the onAppear or viewDidAppear methods.
/// When screen_class is not set, Analytics sets a default value based on the UIViewController is in focus when the call is made.
public class ScreenViewEvent: AnalyticsEvent {
    public init(
        screenName: String,
        trackablePolicy: AnalyticsTrackablePolicy,
        targets: [AnalyticsTargetType],
        screenClass: String? = nil
    ) {
        var parameters: [String: String] = [AnalyticsParameterScreenName: screenName]
        if let screenClass = screenClass {
            parameters[AnalyticsParameterScreenClass] = screenClass
        }
        super.init(
            name: AnalyticsEventScreenView,
            trackablePolicy: trackablePolicy,
            targets: targets,
            parameters: parameters
        )
    }
}
