import UIKit

public protocol TabBarItemView where Self: UIView {
    func setSelected(_ isSelected: Bool)
}

public struct TabBarItemViewModel {
    public let icon: UIImage?
    public let title: String?

    public init(
        icon: UIImage?,
        title: String? = nil
    ) {
        self.icon = icon
        self.title = title
    }
}
