import Foundation

enum SearchModelItemStatus {
    case fed
    case pending
    case starved
}

enum SearchModelItemCategory: Int, CaseIterable {
    case dogs
    case cats

    var text: String {
        switch self {
        case .dogs:
            return L10n.Segment.dogs
        case .cats:
            return L10n.Segment.cats
        }
    }
}

struct SearchModelItem {
    let identifier: String
    let name: String
    let description: String?
    let icon: String?
    let status: SearchModelItemStatus
    let category: SearchModelItemCategory
}

extension SearchModelItemStatus {
    init(_ pointStatus: FeedingPointStatus) {
        switch pointStatus {
        case .fed:
            self = .fed
        case .pending:
            self = .pending
        case .starved:
            self = .starved
        }
    }
}

extension SearchModelItemCategory {
    init(_ pointPet: CategoryTag) {
        switch pointPet {
        case .cats:
            self = .cats
        case .dogs:
            self = .dogs
        }
    }
}
