import Foundation

enum SearchModelItemStatus {
    case fed
    case pending
    case starved
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

struct SearchModelItem {
    let identifier: String
    let name: String
    let description: String?
    let icon: String?
    let status: SearchModelItemStatus
}
