import Foundation

public struct Style<Component: Stylable> {
    private let process: (Component) -> Void

    // MARK: - Initialization
    public init(process: @escaping (Component) -> Void) {
        self.process = process
    }

    // MARK: - Stylization
    public static func compose(_ styles: Style<Component>...) -> Style<Component> {
        return Style { component in
            for style in styles {
                style.apply(to: component)
            }
        }
    }

    public func apply(to component: Component) {
        process(component)
    }

    public func apply(to views: Component...) {
        for view in views {
            apply(to: view)
        }
    }
}
