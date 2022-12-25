import UIKit

public protocol FavouriteCell where Self: UITableViewCell {
    static var reuseIdentifier: String { get }
    func configure(_ item: FavouriteItem)
}
