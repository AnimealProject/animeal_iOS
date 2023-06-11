import Foundation
import UIComponents
import Common

protocol FeedingPointDetailsModelMapperProtocol {
    func map(
        _ item: FeedingPoint,
        isFavorite: Bool,
        isEnabled: Bool
    ) -> FeedingPointDetailsModel.PointContent

    func map(
        _ item: FeedingPoint,
        isFavorite: Bool,
        isEnabled: Bool,
        feeders: [FeedingPointDetailsModel.Feeder]
    ) -> FeedingPointDetailsModel.PointContent

    func map(
        history: [FeedingHistory],
        namesMap: [String: String]
    ) -> [FeedingPointDetailsModel.Feeder]
}

final class FeedingPointDetailsModelMapper: FeedingPointDetailsModelMapperProtocol {
    func map(
        _ item: FeedingPoint,
        isFavorite: Bool,
        isEnabled: Bool,
        feeders: [FeedingPointDetailsModel.Feeder]
    ) -> FeedingPointDetailsModel.PointContent {
        FeedingPointDetailsModel.PointContent(
            content: FeedingPointDetailsModel.Content(
                header: FeedingPointDetailsModel.Header(
                    cover: item.cover,
                    title: item.localizedName.removeHtmlTags()
                ), description: FeedingPointDetailsModel.Description(
                    text: item.localizedDescription.removeHtmlTags()
                ),
                status: convertStatus(item.status),
                feeders: feeders,
                isFavorite: isFavorite
            ), action: FeedingPointDetailsModel.Action(
                identifier: UUID().uuidString,
                title: L10n.Action.iWillFeed,
                isEnabled: isEnabled
            )
        )
    }

    func map(
        _ item: FeedingPoint,
        isFavorite: Bool,
        isEnabled: Bool
    ) -> FeedingPointDetailsModel.PointContent {
        map(
            item,
            isFavorite: isFavorite,
            isEnabled: isEnabled,
            feeders: []
        )
    }

    private func convertStatus(_ status: FeedingPointStatus) -> FeedingPointDetailsModel.Status {
        switch status {
        case .fed:
            return .success(L10n.Feeding.Status.fed)
        case .starved:
            return .error(L10n.Feeding.Status.starved)
        case .pending:
            return .attention(L10n.Feeding.Status.inprogress)
        }
    }

    func map(history: [FeedingHistory], namesMap: [String: String]) -> [FeedingPointDetailsModel.Feeder] {
        return history.map { historyItem in
            let lastFeeded: String
            switch historyItem.status {
            case .inProgress:
                let minutesLeft = DateFormatter.relativeShort.localizedString(
                    for: historyItem.updatedAt.foundationDate,
                    relativeTo: NetTime.now
                )
                lastFeeded = "\(L10n.Feeding.Status.inprogress), \(minutesLeft)"

            default:
                lastFeeded = DateFormatter.relativeFull.localizedString(
                    for: historyItem.updatedAt.foundationDate,
                    relativeTo: NetTime.now
                )
            }
            return FeedingPointDetailsModel.Feeder(
                name: namesMap[historyItem.userId] ?? "Unknown",
                lastFeeded: lastFeeded
            )
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
            return name
        default:
            return i18n?.first(where: { $0.locale == "en" })?.name ?? .empty
        }
    }

    var localizedCity: String {
        switch Locale.current.languageCode {
        case "ka":
            return city
        default:
            return i18n?.first(where: { $0.locale == "en" })?.city ?? .empty
        }
    }
}

private extension DateFormatter {
    /// Full units style relative date time formatter
    ///
    /// Produces relative strings like: "34 minutes ago", "2 hour ago" or "yesterday"
    static let relativeFull: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter
    }()

    /// Short units style relative date time formatter
    ///
    /// Produces relative strings like: "34 min. ago", "2 h. ago" or "1 mo. ago"
    static let relativeShort: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        return formatter
    }()
}
