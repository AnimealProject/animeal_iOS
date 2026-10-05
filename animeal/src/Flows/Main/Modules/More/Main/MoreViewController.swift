import UIKit
import UIComponents
import Style
import Common

final class MoreViewController: UIViewController, MoreViewable, ScreenAccessible {
    static var screenIdentifier: String { MoreViewModel.AccessibilityID.screen }
    // MARK: - UI properties
    private let viewModel: MoreViewModelProtocol
    private let contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    private let footerContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.isHidden = true
        return stack
    }()
    private let logoutButton = ButtonViewFactory().makeAccentInvertedButton()
    private var footerHeightConstraint: NSLayoutConstraint?

    private enum Constants {
        static let untitledSectionSpacing: CGFloat = 20
        static let titledSectionSpacing: CGFloat = 50
    }

    // MARK: - Initialization
    init(viewModel: MoreViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyScreenIdentifier()
        setup()
        viewModel.load()
    }

    func applySections(_ sections: [MoreSectionView]) {
        contentView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, section) in sections.enumerated() {
            if index > 0 {
                let spacing = section.title != nil
                    ? Constants.titledSectionSpacing
                    : Constants.untitledSectionSpacing
                contentView.addArrangedSubview(Self.makeSpacer(height: spacing))
            }
            if let title = section.title {
                contentView.addArrangedSubview(makeSectionTitle(title))
            }
            section.items.forEach { viewItem in
                let view = TitleDisclosureView()
                view.configure(
                    TitleDisclosureView.Model(
                        identifier: viewItem.identifier,
                        title: viewItem.title,
                        hasIndicator: viewItem.hasIndicator,
                        accessibilityIdentifier: MoreViewModel.AccessibilityID.item(viewItem.identifier)
                    )
                )
                view.onTapHandler = { [weak self] identifier in
                    self?.viewModel.handleActionEvent(
                        MoreViewActionEvent.tapInside(identifier)
                    )
                }
                contentView.addArrangedSubview(view)
            }
        }
    }

    private func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = designEngine.fonts.primary.bold(16)
        label.textColor = designEngine.colors.textPrimary
        label.numberOfLines = 1
        label.accessibilityIdentifier = MoreViewModel.AccessibilityID.adminToolsHeader
        label.accessibilityTraits = .header
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }

    private static func makeSpacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.heightAnchor ~= height
        spacer.setContentHuggingPriority(.required, for: .vertical)
        spacer.setContentCompressionResistancePriority(.required, for: .vertical)
        return spacer
    }

    func applyLogoutButton(isVisible: Bool) {
        footerContainerView.isHidden = !isVisible
        footerHeightConstraint?.constant = isVisible ? 60 : 0
    }

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        let headerLabel = UILabel()
        headerLabel.font = designEngine.fonts.primary.bold(28)
        headerLabel.textColor = designEngine.colors.textPrimary
        headerLabel.numberOfLines = 1
        headerLabel.text = L10n.TabBar.more

        view.addSubview(headerLabel.prepareForAutoLayout())
        headerLabel.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        headerLabel.leadingAnchor ~= view.leadingAnchor + 26.0
        headerLabel.trailingAnchor ~= view.trailingAnchor - 26.0

        view.addSubview(contentView.prepareForAutoLayout())
        contentView.topAnchor ~= headerLabel.bottomAnchor + 8
        contentView.leadingAnchor ~= view.leadingAnchor + 26.0
        contentView.trailingAnchor ~= view.trailingAnchor - 26.0
        contentView.accessibilityIdentifier = MoreViewModel.AccessibilityID.list

        logoutButton.configure(
            ButtonView.Model(
                identifier: "logout",
                viewType: ButtonView.self,
                icon: nil,
                title: L10n.Action.logOut,
                accessibilityIdentifier: MoreViewModel.AccessibilityID.logoutButton
            )
        )
        logoutButton.onTap = { [weak self] _ in
            self?.presentLogoutAlert()
        }
        footerContainerView.addArrangedSubview(logoutButton)

        view.addSubview(footerContainerView.prepareForAutoLayout())
        footerContainerView.leadingAnchor ~= view.leadingAnchor + 26.0
        footerContainerView.trailingAnchor ~= view.trailingAnchor - 26.0
        footerContainerView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 40
        footerHeightConstraint = footerContainerView.heightAnchor ~= 60
        contentView.bottomAnchor <= footerContainerView.topAnchor - 16
    }

    private func presentLogoutAlert() {
        let alertViewController = AlertViewController(title: L10n.Question.logoutAccount)
        alertViewController.addAction(
            AlertAction(
                title: L10n.Action.cancel,
                style: .inverted,
                handler: {
                    alertViewController.dismiss(animated: true)
                },
                accessibilityIdentifier: MoreViewModel.AccessibilityID.alertCancel
            )
        )
        alertViewController.addAction(
            AlertAction(
                title: L10n.Action.logOut,
                style: .accent,
                handler: { [weak self] in
                    alertViewController.dismiss(animated: true)
                    self?.viewModel.handleActionEvent(.logout)
                },
                accessibilityIdentifier: MoreViewModel.AccessibilityID.alertConfirm
            )
        )
        present(alertViewController, animated: true)
    }
}
