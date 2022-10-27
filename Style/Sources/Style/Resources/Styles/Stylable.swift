import UIKit

public typealias Stylable = UIAppearance

public extension Stylable {
    @discardableResult
    func apply(style: Style<Self>) -> Self {
        style.apply(to: self)
        return self
    }

    @discardableResult
    func apply(styles: Style<Self>...) -> Self {
        for style in styles {
            apply(style: style)
        }

        return self
    }
}
