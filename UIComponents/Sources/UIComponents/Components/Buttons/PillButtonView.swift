import UIKit

open class PillButtonView: ButtonView {
    // MARK: - Constants
    private enum Constants {
        static let height: CGFloat = 32
        static let cornerRadius: CGFloat = 16
        static let horizontalInset: CGFloat = 16
        static let titleFontSize: CGFloat = 16
        static let shadowOpacity: Float = 0.08
        static let shadowRadius: CGFloat = 8
        static let shadowOffset = CGSize(width: 0, height: 2)
    }

    // MARK: - Configuration
    public override func configure(_ model: ButtonView.Model) {
        identifier = model.identifier
        contentView.configuration?.title = model.title
        contentView.accessibilityIdentifier = model.accessibilityIdentifier
        assert(model.icon == nil, "\(Self.self) doesn't support icon")
    }

    public func setSelected(_ isSelected: Bool) {
        contentView.isSelected = isSelected
    }

    // MARK: - Setup
    public override func setup() {
        addSubview(contentView.prepareForAutoLayout())
        contentView.leadingAnchor ~= leadingAnchor
        contentView.topAnchor ~= topAnchor
        contentView.trailingAnchor ~= trailingAnchor
        contentView.bottomAnchor ~= bottomAnchor
        contentView.heightAnchor ~= Constants.height

        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.clipsToBounds = true
        contentView.configuration = makeConfiguration()
        contentView.configurationUpdateHandler = { [weak self] button in
            self?.applyAppearance(to: button)
        }

        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = Constants.shadowOffset
        layer.shadowRadius = Constants.shadowRadius

        contentView.addTarget(
            self,
            action: #selector(buttonWasPressed(_:)),
            for: .touchUpInside
        )
    }

    // MARK: - Appearance
    private func makeConfiguration() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.plain()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: Constants.horizontalInset,
            bottom: 0,
            trailing: Constants.horizontalInset
        )
        return configuration
    }

    private func applyAppearance(to button: UIButton) {
        guard var configuration = button.configuration else { return }

        let foreground = button.isSelected
            ? designEngine.colors.alwaysLight
            : designEngine.colors.textPrimary
        let highlightedAlpha: CGFloat = button.isSelected ? 0.7 : 0.6
        let resolvedForeground = button.isHighlighted
            ? foreground.withAlphaComponent(highlightedAlpha)
            : foreground
        let font = designEngine.fonts.primary.semibold(Constants.titleFontSize)

        configuration.baseForegroundColor = resolvedForeground
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            outgoing.foregroundColor = resolvedForeground
            return outgoing
        }
        configuration.background.backgroundColor = button.isSelected
            ? designEngine.colors.accent
            : designEngine.colors.backgroundPrimary
        button.configuration = configuration
    }
}
