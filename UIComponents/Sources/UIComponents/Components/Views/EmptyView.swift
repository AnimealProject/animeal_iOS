// System
import UIKit

// SDK
import Style

public extension EmptyView {
    struct Model {
        public let title: String

        public init(title: String) {
            self.title = title
        }
    }
}

public final class EmptyView: UIView {
    // MARK: - Constants
    private enum Constants {
        static let contentInsets = UIEdgeInsets(
            top: 32.0, left: 64.0, bottom: 32.0, right: 64.0
        )
    }

    // MARK: - UI properties
    lazy var textView = UILabel().prepareForAutoLayout()

    // MARK: - Initialization
    public init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        textView.text = model.title
    }

    // MARK: - Setup
    private func setup() {
        addSubview(textView)

        textView.centerXAnchor ~= centerXAnchor
        textView.centerYAnchor ~= centerYAnchor

        let leadingConstraint = textView.leadingAnchor.constraint(
            greaterThanOrEqualTo: leadingAnchor,
            constant: Constants.contentInsets.left
        )
        leadingConstraint.priority = .init(999)
        leadingConstraint.isActive = true

        let topConstraint = textView.topAnchor.constraint(
            greaterThanOrEqualTo: topAnchor,
            constant: Constants.contentInsets.top
        )
        topConstraint.priority = .init(999)
        topConstraint.isActive = true

        apply(style: .default)
    }
}

extension Style where Component: EmptyView {
    static var `default`: Style {
        Style { component in
            let designEngine = component.designEngine
            component.textView.font = designEngine.fonts.primary.regular(16.0)
            component.textView.textColor = designEngine.colors.textSecondary
            component.textView.numberOfLines = 0
            component.textView.textAlignment = .center
        }
    }
}
