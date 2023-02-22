import UIKit

open class CircleButtonView: ButtonView {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 54
        static let width: CGFloat = 54
        static let cornerRadius: CGFloat = 27
    }

    // MARK: - Configuration
    public override func configure(_ model: ButtonView.Model) {
        identifier = model.identifier
        contentView.setImage(
            model.icon?.withTintColor(designEngine.colors.textPrimary),
            for: UIControl.State.normal
        )
        contentView.setImage(
            model.icon?.withTintColor(designEngine.colors.accent),
            for: UIControl.State.highlighted
        )
    }

    // MARK: - Setup
    public override func setup() {
        addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor ~= leadingAnchor
        contentView.topAnchor ~= topAnchor
        contentView.trailingAnchor ~= trailingAnchor
        contentView.bottomAnchor ~= bottomAnchor
        contentView.heightAnchor ~= Constants.height
        contentView.widthAnchor ~= Constants.width
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.backgroundColor = designEngine.colors.backgroundPrimary

        contentView.layer.masksToBounds = false
        contentView.layer.shadowColor = designEngine.colors.backgroundPrimary.cgColor
        contentView.layer.shadowOpacity = 0.16
        contentView.layer.shadowOffset = CGSize(width: 0, height: 3)
        contentView.layer.shadowRadius = 6

        contentView.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: UIControl.Event.touchUpInside
        )
    }
}
