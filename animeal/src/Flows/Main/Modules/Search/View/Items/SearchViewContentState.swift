import UIKit

enum SearchViewContentState {
    case snapshot(SearchViewSnapshot)
    case empty(SearchViewEmpty)
}

typealias SearchViewSnapshot = NSDiffableDataSourceSnapshot<
    SearchViewSectionWrapper, SearchViewItemlWrapper
>

extension SearchViewSnapshot {
    static var empty: SearchViewSnapshot {
        SearchViewSnapshot()
    }
}

struct SearchViewEmpty {
    let text: String
}
