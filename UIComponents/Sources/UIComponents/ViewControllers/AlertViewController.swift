import UIKit

/// AlertViewController
///
/// Usage example:
///
///     let alert = AlertViewController(
///         title: "Some Title"
///     )
///     alert.addAction(
///         AlertAction(title: "Action title", style: AlertAction.Style.inverted, handler: { })
///     )
///
///     present(alert, animated: true)
///
public final class AlertViewController: UIViewController {
    // MARK: - Private properties
    private let actionsContainer = UIStackView()
    private let transitionController = ZoomTransitionController()

    // MARK: - Initialization
    public init(title: String, image: UIImage? = nil) {
        super.init(nibName: nil, bundle: nil)

        self.transitioningDelegate = transitionController
        self.modalPresentationStyle = .custom

        setup(title: title, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    public func addAction(_ action: AlertAction) {
        let factory = ButtonViewFactory()
        var button: ButtonView
        switch action.style {
        case .accent:
            button = factory.makeAccentButton()
        case .inverted:
            button = factory.makeAccentInvertedButton()
        }

        button.configure(
            ButtonView.Model(
                identifier: UUID().uuidString,
                viewType: ButtonView.self,
                title: action.title ?? .empty
            )
        )
        button.onTap = { _ in
            action.handler?()
        }
        actionsContainer.addArrangedSubview(button)
    }

    // MARK: - Private API
    private func setup(title: String, image: UIImage?) {
        let dialogView = UIView()
        dialogView.layer.cornerRadius = 30

        view.addSubview(dialogView.prepareForAutoLayout())
        dialogView.leadingAnchor ~= view.leadingAnchor + 36
        dialogView.trailingAnchor ~= view.trailingAnchor - 36
        dialogView.centerXAnchor ~= view.centerXAnchor
        dialogView.centerYAnchor ~= view.centerYAnchor
        dialogView.backgroundColor = designEngine.colors.backgroundPrimary.uiColor

        let contentView = UIStackView()
        contentView.axis = .horizontal

        dialogView.addSubview(contentView.prepareForAutoLayout())
        contentView.topAnchor ~= dialogView.topAnchor + 26
        contentView.leadingAnchor ~= dialogView.leadingAnchor + 26
        contentView.trailingAnchor ~= dialogView.trailingAnchor - 26
        contentView.axis = .vertical

        dialogView.addSubview(actionsContainer.prepareForAutoLayout())
        actionsContainer.topAnchor ~= contentView.bottomAnchor + 28
        actionsContainer.leadingAnchor ~= dialogView.leadingAnchor + 26
        actionsContainer.trailingAnchor ~= dialogView.trailingAnchor - 26
        actionsContainer.bottomAnchor ~= dialogView.bottomAnchor - 26
        actionsContainer.distribution = .fillEqually
        actionsContainer.spacing = 12

        let titleLabel = UILabel()
        titleLabel.font = designEngine.fonts.primary.bold(18).uiFont
        titleLabel.textColor = designEngine.colors.textPrimary.uiColor
        titleLabel.numberOfLines = 0
        titleLabel.text = title

        contentView.addArrangedSubview(titleLabel)

        if let image = image {
            let spacerView = UIView().prepareForAutoLayout()
            spacerView.heightAnchor ~= 26
            contentView.addArrangedSubview(spacerView)

            let imageView = UIImageView()
            imageView.image = image
            imageView.layer.cornerRadius = 16

            contentView.addArrangedSubview(imageView)
        }
    }
}

// MARK: - AlertAction model
public struct AlertAction {
    public let title: String?
    public let style: Style
    public let handler: (() -> Void)?

    public enum Style {
        case accent
        case inverted
    }

    public init(
        title: String? = nil,
        style: Style,
        handler: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
