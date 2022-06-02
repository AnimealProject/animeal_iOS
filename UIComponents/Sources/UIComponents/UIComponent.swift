import Style

public struct UIComponent {
    public private(set) var text = "Hello, World!"

    public init() {
    }
    
    public func foo() {
        let a = AnyStyle()
        
        print(a.text)
    }
}
