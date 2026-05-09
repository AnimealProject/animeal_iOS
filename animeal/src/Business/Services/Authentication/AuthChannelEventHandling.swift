import Foundation

protocol AuthChannelEventsPublisher {
    func subscribe(_ listener: AuthChannelEventsListener)
}

@MainActor
protocol AuthChannelEventsListener: AnyObject {
    func listenAuthChannelEvents(event: AuthChannelEvents)
}

enum AuthChannelEvents {
    case sessionExpired
}
