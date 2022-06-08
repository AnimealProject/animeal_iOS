import UIKit

public struct AnyStyle {
    public private(set) var text = "Hello, World!"

    public init() {
    }
}

public extension ImageAsset.Image {
    convenience init?(named: String) {
        self.init(named: named, in: BundleToken.bundle, compatibleWith: nil)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
        return Bundle.module
    }()
}
// swiftlint:enable convenience_type
