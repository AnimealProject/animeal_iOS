import UIKit

protocol TabBarView where Self: UIView {
    var onSelectedItemUpdate: (() -> Void)? { get set }
    var selectedItem: TabBarItemView? { get }
    var selectedItemIndex: Int? { get }

    func setItems(_ items: [TabBarItemView])
    func setSelectedIndex(_ index: Int?)
}
