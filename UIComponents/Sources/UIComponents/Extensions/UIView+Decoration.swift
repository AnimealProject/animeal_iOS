import UIKit

public extension UIView {
    @discardableResult
    func cornerRadius(_ radius: CGFloat = 6.0) -> Self {
        layer.cornerRadius = radius
        return self
    }

    @discardableResult
    func shadow(
        color: UIColor? = UIColor.black,
        opacity: Float = 0.09,
        offset: CGSize = CGSize(width: 0.0, height: 2.0),
        radius: CGFloat = 4.0
    ) -> Self {
        layer.shadowColor = color?.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        return self
    }

    @discardableResult
    func border(
        color: UIColor? = UIColor.black,
        width: CGFloat
    ) -> Self {
        layer.borderColor = color?.cgColor
        layer.borderWidth = width
        return self
    }
}
