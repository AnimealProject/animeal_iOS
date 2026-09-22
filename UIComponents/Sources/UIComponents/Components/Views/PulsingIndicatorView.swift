import UIKit

public final class PulsingIndicatorView: UIView {
    private enum Constants {
        static let size: CGFloat = 5
        static let minScale: CGFloat = 0.6
        static let halfCycleDuration: TimeInterval = 0.5
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: Constants.size, height: Constants.size)
    }

    public init() {
        super.init(frame: .zero)
        layer.cornerRadius = Constants.size / 2
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func startAnimating() {
        stopAnimating()
        UIView.animate(withDuration: Constants.halfCycleDuration, delay: 0, options: [.repeat, .autoreverse]) {
            self.transform = CGAffineTransform(scaleX: Constants.minScale, y: Constants.minScale)
        }
    }

    public func stopAnimating() {
        layer.removeAllAnimations()
        transform = .identity
    }
}
