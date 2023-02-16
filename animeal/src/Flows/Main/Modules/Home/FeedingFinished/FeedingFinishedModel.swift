import Foundation

final class FeedingFinishedModel: FeedingFinishedModelProtocol, ObservableObject {
    // MARK: - Private properties

    // MARK: - Initialization
    init() { }
}

// MARK: - Preview
extension FeedingFinishedModel {
    static var previewModel: FeedingFinishedModel {
        return FeedingFinishedModel()
    }
}
