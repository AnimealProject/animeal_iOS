import UIKit

public protocol AnalyticsTrackableScreen {
    /// this func is used to attach ANY info to analytics event for the view controller appear event (or any other)
    /// default implementation return nothing
    /// override to customize
    func analyticsPayload() -> [String: String]
}

public extension AnalyticsTrackableScreen {
    func analyticsPayload() -> [String: String] {
        return [:]
    }
}

public enum AnalyticsScreen {
    case screen(class: String)

    /// special string describing screen
    public var description: String {
        switch self {
        case let .screen(classString):
            return "\(classString)"
        }
    }

    public static func screenForViewController(
        _ viewController: UIViewController
    ) -> AnalyticsScreen {
        let classString = viewController.classForCoder.description()
        return .screen(class: classString)
    }
}
