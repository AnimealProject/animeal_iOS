import UIKit

open class TextButtonView: ButtonView {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 44
    }

    // MARK: - Configuration
    public override func configure(_ model: ButtonView.Model) {
        identifier = model.identifier

        let title = NSAttributedString(string: model.title, attributes: [
            .foregroundColor: contentView.designEngine.colors.accent,
            .font: contentView.designEngine.fonts.secondary.light(16) ?? .systemFont(ofSize: 16, weight: .light),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        contentView.setAttributedTitle(title, for: .normal)
        assert(model.icon == nil, "\(Self.self) doesn't support icon")
    }

    // MARK: - Setup
    public override func setup() {
        addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor ~= leadingAnchor
        contentView.topAnchor ~= topAnchor
        contentView.trailingAnchor ~= trailingAnchor
        contentView.bottomAnchor ~= bottomAnchor
        contentView.heightAnchor ~= Constants.height

        contentView.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
    }
}
