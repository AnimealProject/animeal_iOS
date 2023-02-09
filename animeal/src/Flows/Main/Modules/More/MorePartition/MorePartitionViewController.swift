import UIKit
import UIComponents

final class MorePartitionViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: MorePartitionViewModelProtocol
    private let headerContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    private let contentContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    private let footerContainerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    // MARK: - Initialization
    init(viewModel: MorePartitionViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationBar()
        viewModel.load()
    }
}

extension MorePartitionViewController: MorePartitionViewable {
    func applyContentModel(_ model: PartitionContentModel) {
        applyHeader(model.header)
        applyContent(model.content)
        applyFooter(model.footer)
    }
}

private extension MorePartitionViewController {
    func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        view.addSubview(headerContainerView.prepareForAutoLayout())
        headerContainerView.leadingAnchor ~= view.leadingAnchor + 26.0
        headerContainerView.trailingAnchor ~= view.trailingAnchor - 26.0
        headerContainerView.topAnchor ~= view.safeAreaLayoutGuide.topAnchor
        headerContainerView.heightAnchor ~= 40

        view.addSubview(contentContainerView.prepareForAutoLayout())
        contentContainerView.topAnchor ~= headerContainerView.bottomAnchor + 16
        contentContainerView.leadingAnchor ~= view.leadingAnchor + 26.0
        contentContainerView.trailingAnchor ~= view.trailingAnchor - 26.0

        view.addSubview(footerContainerView.prepareForAutoLayout())
        footerContainerView.topAnchor ~= contentContainerView.bottomAnchor
        footerContainerView.leadingAnchor ~= view.leadingAnchor + 26.0
        footerContainerView.trailingAnchor ~= view.trailingAnchor - 26.0
        footerContainerView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 40
        footerContainerView.heightAnchor ~= 60
    }

    func setupNavigationBar() {
        navigationItem.backBarButtonItem = .back(target: self, action: #selector(barButtonItemTapped))
    }

    @objc func barButtonItemTapped() {
        viewModel.handleActionEvent(.back)
    }

    func applyHeader(_ model: PartitionContentModel.Header) {
        let headerLabel = UILabel()
        headerLabel.font = designEngine.fonts.primary.bold(28)
        headerLabel.textColor = designEngine.colors.textPrimary
        headerLabel.numberOfLines = 1
        headerLabel.text = model.title

        headerContainerView.addArrangedSubview(UIView())
        headerContainerView.addArrangedSubview(headerLabel)
    }

    func applyContent(_ model: PartitionContentModel.Content) {
        if let actions = model.actions {
            actions.forEach { action in
                let actionView = DestructiveActionView()
                actionView.configure(
                    DestructiveActionView.Model(
                        title: action.title,
                        image: UIImage(systemName: "trash")
                    )
                )
                actionView.actionHandler = { [weak self] in
                    guard let self = self else { return }
                    if let alert = self.makeAlertView(action.dialog) {
                        self.present(alert, animated: true)
                    }
                }
                contentContainerView.addArrangedSubview(actionView)
                contentContainerView.addArrangedSubview(UIView())
            }
        }

        if let block = model.bottomTextBlock {
            let label = UILabel()
            label.text = block.title
            label.font = designEngine.fonts.primary.regular(16)
            label.textColor = designEngine.colors.textPrimary
            label.textAlignment = .center
            contentContainerView.addArrangedSubview(UIView())
            contentContainerView.addArrangedSubview(label)

            contentContainerView.bottomAnchor ~= view.safeAreaLayoutGuide.bottomAnchor - 40
            footerContainerView.removeFromSuperview()
        }
    }

    func applyFooter(_ model: PartitionContentModel.Footer?) {
        guard let footer = model else { return }
        let factory = ButtonViewFactory()
        var button: ButtonView

        switch footer.action.type {
        case .accent:
            button = factory.makeAccentButton()
        case .inverted:
            button = factory.makeAccentInvertedButton()
        }

        button.configure(
            ButtonView.Model(
                identifier: UUID().uuidString,
                viewType: ButtonView.self,
                icon: nil,
                title: footer.action.title
            )
        )
        button.onTap = { [weak self] _ in
            guard let self = self else { return }
            if let alert = self.makeAlertView(footer.action.dialog) {
                self.present(alert, animated: true)
            } else {
                switch footer.action.actionId {
                case .none:
                    break
                case .copyIBAN:
                    self.viewModel.handleActionEvent(.copyIBAN)
                }
            }
        }

        footerContainerView.addArrangedSubview(button)
        footerContainerView.addArrangedSubview(UIView())
    }

    func makeAlertView(_ dialogModel: PartitionContentModel.Dialog?) -> AlertViewController? {
        guard let model = dialogModel else { return nil }
        let alertViewController = AlertViewController(title: model.title)

        model.actions.forEach { action in
            var style: AlertAction.Style
            switch action.style {
            case .accent:
                style = .accent
            case .inverted:
                style = .inverted
            }
            alertViewController.addAction(
                AlertAction(title: action.title, style: style) { [weak self] in
                    guard let self = self else { return }
                    switch action.actionId {
                    case .delete:
                        self.viewModel.handleActionEvent(.deleteAccount)
                    case .logout:
                        self.viewModel.handleActionEvent(.logout)
                    case .cancel:
                        break
                    }
                    alertViewController.dismiss(animated: true)
                }
            )
        }
        return alertViewController
    }
}
