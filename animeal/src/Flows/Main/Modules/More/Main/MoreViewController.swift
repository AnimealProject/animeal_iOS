import UIKit
import UIComponents
import Style
import Common

final class MoreViewController: UIViewController, MoreViewable {
    // MARK: - UI properties
    private let viewModel: MoreViewModelProtocol
    private let contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

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
        setup()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customTabBarController?.setTabBarHidden(false, animated: true)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func applyActions(_ viewItems: [MoreItemView]) {
        viewItems.forEach { viewItem in
            let view = TitleDisclosureView()
            view.configure(
                TitleDisclosureView.Model(
                    identifier: viewItem.identifier,
                    title: viewItem.title
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

    // MARK: - Setup
    private func setup() {
        view.backgroundColor = designEngine.colors.backgroundPrimary

        let headerLabel = UILabel()
        headerLabel.font = designEngine.fonts.primary.bold(28)
        headerLabel.textColor = designEngine.colors.textPrimary
        headerLabel.numberOfLines = 1
        headerLabel.text = L10n.TabBar.more

        view.addSubview(headerLabel.prepareForAutoLayout())
        headerLabel.topAnchor ~= view.safeAreaLayoutGuide.topAnchor + 36
        headerLabel.leadingAnchor ~= view.leadingAnchor + 26.0
        headerLabel.trailingAnchor ~= view.trailingAnchor - 26.0

        view.addSubview(contentView.prepareForAutoLayout())
        contentView.topAnchor ~= headerLabel.bottomAnchor + 8
        contentView.leadingAnchor ~= view.leadingAnchor + 26.0
        contentView.trailingAnchor ~= view.trailingAnchor - 26.0
    }
}
