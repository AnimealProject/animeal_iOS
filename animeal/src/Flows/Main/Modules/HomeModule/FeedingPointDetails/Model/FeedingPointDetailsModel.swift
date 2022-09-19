import Foundation

final class FeedingPointDetailsModel: FeedingPointDetailsModelProtocol {
    // MARK: - Private properties

    // MARK: - Initialization
    init() { }

    func fetchFeedingPoints(_ completion: ((FeedingPointDetailsModel.PointContent) -> Void)?) {
        // TODO: Replace below with real data
        let content = PointContent(
            content: Content(
                header: Header(
                    title: "Near to Bukia Garden M.S Technical University"
                ), description: Description(
                    text: "This area covers about 100 sq.m. -S,"
                    + " it starts with Bukia Garden and Sports At the palace."
                    + " There are about 1000 homeless people here The dog lives with the habit"
                    + " of helping You need."
                )
            ), action: Action(
                identifier: UUID().uuidString, title: L10n.Action.iWillFeed
            )
        )
        completion?(content)
    }
}

extension FeedingPointDetailsModel {
    struct PointContent {
        let content: Content
        let action: Action
    }

    struct Content {
        let header: Header
        let description: Description
    }

    struct Header {
        let title: String
    }

    struct Description {
        let text: String
    }

    struct Action {
        let identifier: String
        let title: String
    }
}
