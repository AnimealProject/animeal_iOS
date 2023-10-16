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

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        apply(style: .deviceShimmerMaskContentStyle)
    }
}

private extension Style where Component: ShimmerMaskContentView {
    static var deviceShimmerMaskContentStyle: Style {
        return Style {
            $0.backgroundColor = $0.designEngine.colors.backgroundSecondary
            $0.cornerRadius(8.0)
        }
    }
}
