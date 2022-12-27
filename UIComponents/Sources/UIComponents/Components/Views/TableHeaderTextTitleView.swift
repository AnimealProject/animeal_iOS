import Foundation
import UIKit

public final class TableHeaderTextTitleView: UIView {
    // MARK: - Private properties
    private lazy var titleLabel = UILabel()

    // MARK: - Initialization
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    public func configure(_ model: Model) {
        titleLabel.text = model.title
        titleLabel.font = designEngine.fonts.primary.bold(model.fontSize).uiFont
        titleLabel.textColor = designEngine.colors.textPrimary.uiColor
    }
}

private extension TableHeaderTextTitleView {
    // MARK: - Setup
    func setup() {
        addSubview(titleLabel.prepareForAutoLayout())
        titleLabel.leadingAnchor ~= leadingAnchor
        titleLabel.trailingAnchor ~= trailingAnchor - 20
        titleLabel.topAnchor ~= topAnchor + 24
        titleLabel.bottomAnchor ~= bottomAnchor - 40
    }
}

// MARK: - Model
public extension TableHeaderTextTitleView {
    struct Model {
        public let title: String
        public let fontSize: CGFloat

        public init(title: String, fontSize: CGFloat) {
            self.title = title
            self.fontSize = fontSize
        }
    }
}
