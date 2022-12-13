import Foundation
import UIComponents
import Common

protocol FeedingPointDetailsModelMapperProtocol {
    func map(_ item: FeedingPoint) -> FeedingPointDetailsModel.PointContent
}

class FeedingPointDetailsModelMapper: FeedingPointDetailsModelMapperProtocol {
    func map(_ item: FeedingPoint) -> FeedingPointDetailsModel.PointContent {
        // Back-end not ready present feeders list yet
        let feeders: [FeedingPointDetailsModel.Feeder] = []
        return  FeedingPointDetailsModel.PointContent(
            content: FeedingPointDetailsModel.Content(
                header: FeedingPointDetailsModel.Header(
                    cover: item.cover,
                    title: item.localizedName.removeHtmlTags()
                ), description: FeedingPointDetailsModel.Description(
                    text: item.localizedDescription.removeHtmlTags()
                ),
                status: convertStatus(item.status),
                feeders: feeders
            ), action: FeedingPointDetailsModel.Action(
                identifier: UUID().uuidString,
                title: L10n.Action.iWillFeed,
                isEnabled: item.status == .starved
            )
        )
    }

    private func convertStatus(_ status: FeedingPointStatus) -> FeedingPointDetailsModel.Status {
        switch status {
        case .fed:
            return .success(L10n.Feeding.Status.fed)
        case .starved:
            return .error(L10n.Feeding.Status.starved)
        case .pending:
            // TODO: fix time interval
            return .attention(L10n.Feeding.Status.Pending.pattern("12 Hours"))
        }
    }
}

extension FeedingPoint {
    var localizedDescription: String {
        switch Locale.current.languageCode {
        case "ka":
            return description
        default:
            return i18n?.first(where: { $0.locale == "en" })?.description ?? .empty
        }
    }

    var localizedName: String {
        switch Locale.current.languageCode {
        case "ka":
            return description
        default:
            return i18n?.first(where: { $0.locale == "en" })?.name ?? .empty
        }
    }
}
