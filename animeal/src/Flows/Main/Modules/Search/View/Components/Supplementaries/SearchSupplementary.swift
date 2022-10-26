import UIKit

public protocol SearchSupplementaryContainable where Self: UICollectionReusableView {
    static var reuseIdentifier: String { get }
    static var kind: SearchSupplementaryViewKind { get }

    var onTap: (() -> Void)? { get set }

    func configure(_ item: SearchViewSupplementary)
}
