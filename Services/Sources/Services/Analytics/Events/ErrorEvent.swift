//
//  ErrorEvent.swift
//
//
//  Created by Pran Kishore on 22/09/24.
//

import Foundation
import Firebase

/// Event to  manually log error  events
/// You can log these events for all error events.
/// This will be logged as crashlytics non-fatal error
public class ErrorEvent: AnalyticsEvent {
    public init(
        screenClass: String,
        error: LocalizedError
    ) {
        let trackablePolicy = AnalyticsTrackablePolicy.multipleTracking
        let targets = [AnalyticsTargetType.nonFatal]
        let userInfo = [
            NSLocalizedDescriptionKey: error.localizedDescription,
            NSLocalizedFailureReasonErrorKey: error.failureReason,
            NSLocalizedRecoverySuggestionErrorKey: error.recoverySuggestion,
            AnalyticsParameterScreenClass: screenClass
        ]
        super.init(
            name: AnalyticsEventScreenView,
            trackablePolicy: trackablePolicy,
            targets: targets,
            parameters: userInfo
        )
    }
}
