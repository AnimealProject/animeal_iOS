import UIKit

public protocol SearchCellContainable where Self: UICollectionViewCell {
    static var reuseIdentifier: String { get }

    var didTapOnFavorite: (() -> Void)? { get set }
    var didTapOnContent: (() -> Void)? { get set }

    func configure(_ item: SearchViewItem)
}
