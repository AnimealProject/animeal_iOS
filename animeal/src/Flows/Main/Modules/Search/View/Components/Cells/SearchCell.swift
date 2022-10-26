import UIKit

public protocol SearchCellContainable where Self: UICollectionViewCell {
    static var reuseIdentifier: String { get }

    func configure(_ item: SearchViewItem)
}
