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
                let minutesLeft = DateFormatter.relativeShort.string(
                    from: NetTime.now,
                    to: historyItem.updatedAt.foundationDate
                ) ?? "0"
                lastFeeded = "\(L10n.Feeding.Status.inprogress), \(minutesLeft) \(L10n.Text.left)"

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
        localized?.description ?? description
    }

    var localizedName: String {
        localized?.name ?? name
    }

    var localizedCity: String {
        localized?.city ?? city
    }

    private var localized: FeedingPointI18n? {
        i18n?.first { $0.locale == Locale.current.languageCode }
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

    static let relativeShort: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .short
        return formatter
    }()
}
