import UIKit

public protocol SearchViewSupplementary {
    var viewType: SearchSupplementaryContainable.Type { get }
    var sizerType: SearchSupplementaryViewSizer.Type { get }
    var viewReuseIdentifier: String { get }

    func isEqual(to anotherItem: SearchViewSupplementary) -> Bool
    func hash(into hasher: inout Hasher)
}

public enum SearchSupplementaryViewKind {
    case header
    case footer

    var string: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        }
    }
}
