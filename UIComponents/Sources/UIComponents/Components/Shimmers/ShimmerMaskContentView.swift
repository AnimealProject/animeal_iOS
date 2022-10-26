import UIKit
import Style

public final class ShimmerMaskContentView: UIView {
    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        apply(style: .deviceShimmerMaskContentStyle)
    }
}

fileprivate extension Style where Component: ShimmerMaskContentView {
    static var deviceShimmerMaskContentStyle: Style {
        return Style {
            $0.backgroundColor = .black
            $0.cornerRadius(8.0)
        }
    }
}
