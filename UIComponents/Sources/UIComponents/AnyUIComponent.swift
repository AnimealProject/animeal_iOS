import Style

public struct AnyUIComponent {
    public private(set) var text = "Hello, World!"

    public init() {
    }

    public func foo() {
        let anyStyle = AnyStyle()

        print(anyStyle.text)
    }
}
