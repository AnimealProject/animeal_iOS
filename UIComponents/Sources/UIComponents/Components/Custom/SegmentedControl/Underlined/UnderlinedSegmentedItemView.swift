// System
import UIKit

// SDK
import Style

// MARK: - Model
public extension UnderlinedSegmentedItemView {
    struct Model {
        public let identifier: String
        public let title: String

        public init(identifier: String, title: String) {
            self.identifier = identifier
            self.title = title
        }
    }
}

public final class UnderlinedSegmentedItemView: UIView {
    // MARK: - UI properties
    private(set) var titleView = UILabel().prepareForAutoLayout()

    // MARK: - Properties
    private(set) var identifier = UUID().uuidString

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
        titleView.text = model.title
        identifier = model.identifier
    }

    // MARK: - Setup
    private func setup() {
        addSubview(titleView)

        titleView.centerXAnchor ~= centerXAnchor
        titleView.topAnchor ~= topAnchor + 16.0
        titleView.bottomAnchor ~= bottomAnchor - 16.0
    }
}

public extension Style where Component: UnderlinedSegmentedItemView {
    static var selected: Style {
        return Style { component in
            let designEngine = component.designEngine
            component.backgroundColor = .white
            component.titleView.textColor = designEngine.colors.accent.uiColor
            component.titleView.font = designEngine.fonts.primary.bold(14.0).uiFont
        }
    }

    static var normal: Style {
        return Style { component in
            let designEngine = component.designEngine
            component.backgroundColor = .white
            component.titleView.textColor = designEngine.colors.textSecondary.uiColor
            component.titleView.font = designEngine.fonts.primary.semibold(14.0).uiFont
        }
    }
}
